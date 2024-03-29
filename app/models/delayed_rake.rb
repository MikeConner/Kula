# == Schema Information
#
# Table name: delayed_rakes
#
#  id             :integer          not null, primary key
#  job_identifier :integer
#  name           :string(32)
#  params         :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

# CHARTER
#   Mechanism for running arbitrary rake tasks in a DelayedJob, and reporting on their status
#
# USAGE
#
# NOTES AND WARNINGS
#
class DelayedRake < ActiveRecord::Base
  IMPORT_TX_TASK = 'db:stepwise_import_transactions'
  ETL_REPLICATE_TASK = 'etl:replicate_all'
  CLOSE_YEAR_TASK = 'db:close_year'
  GENERATE_PAYMENT_BATCH_TASK = 'db:generate_payment_batch'

  attr_accessor :delayed_job

  def started_at
    ensure_job

    self.delayed_job.nil? ? nil : self.delayed_job.run_at.to_s
  end

  def failed_at
    ensure_job

    self.delayed_job.nil? ? nil : self.delayed_job.failed_at.to_s
  end

  def attempts
    ensure_job

    self.delayed_job.nil? ? nil : self.delayed_job.attempts
  end

  def last_error
    ensure_job

    error = self.delayed_job.nil? ? nil : self.delayed_job.last_error

    error.blank? ? nil : error[0, 80]
  end

  def args
    s = ""
    unless self.params.blank?
      YAML::load(self.params).each do |k, v|
        s += "#{k}=#{v} " unless v.blank?
      end
    end

    s
  end

  def display_name
    case self.name
    when IMPORT_TX_TASK
      "Import Transactions"
    when ETL_REPLICATE_TASK
      "ETL Table Replication"
    when CLOSE_YEAR_TASK
      "Close Year"
    when GENERATE_PAYMENT_BATCH_TASK
      "Generate Payment Batch"
    else
      "Unknown"
    end
  end

  #attr_accessor :name, :options
  def set_params(options)
    self.params = YAML::dump(options)
  end

  def run_task
    Rake::Task.clear # necessary to avoid tasks being loaded several times in dev mode
    Kula::Application.load_tasks # providing your application name is 'sample'

    if self.params.nil?
      Rake::Task[self.name].invoke
    else
      options = YAML::load(self.params)

      Rake::Task[self.name].invoke(*options.values)
    end
    Rake::Task[self.name].reenable
  end
  handle_asynchronously :run_task

  def self.active_jobs(name = nil)
     active_ids = jobs_in_progress.map(&:id) & DelayedRake.all.map(&:job_identifier)

     if name.nil?
       DelayedRake.where('job_identifier in (?)', active_ids).order(:name)
     else
       DelayedRake.where('job_identifier in (?)', active_ids).where(:name => name)
     end
  end

  def self.failed_jobs
     active_ids = jobs_marked_failed.map(&:id) & DelayedRake.all.map(&:job_identifier)

     DelayedRake.where('job_identifier in (?)', active_ids).order(:name)
  end

private
  def self.jobs_in_progress
    Delayed::Job.select { |dj| !dj.failed? }
  end

  def self.jobs_marked_failed
    Delayed::Job.select { |dj| dj.failed? }
  end

  def ensure_job
    @delayed_job = Delayed::Job.find(self.job_identifier) if @delayed_job.nil?
  end
end
