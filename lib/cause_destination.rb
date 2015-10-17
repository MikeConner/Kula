require 'pg'

class CauseDestination
  # connect_url should look like;
  #  mysql://user:pass@localhost/dbname

  def initialize(connect_url)
    @conn = PG.connect(connect_url)
    @conn.prepare('insert_user_stmt', 'INSERT INTO causes(
            cause_id, source_id, source_cause_id, mcr_school_id, enhanced_date,
            unenhanced_cause_id, tax_id, cause_type, has_ach_info, k8, org_name,
            old_org_name, org_contact_first_name, old_org_contact_first_name,
            org_contact_last_name, old_org_contact_last_name, org_contact_email,
            old_org_contact_email, mcr_role, mcr_user_level, org_email, org_phone,
            old_org_phone, org_fax, mission, additional_description, description,
            address1, old_address1, address2, address3, latitude, longitude,
            city, old_city, region, old_region, country, postal_code, old_postal_code,
            mailing_address, mailing_city, mailing_state, mailing_postal_code,
            site_url, old_site_url, logo_url, logo_small_url, image_url,
            video_url, facebook_url, newsletter_url, photos_url, twitter_username,
            school_grades_desc, school_student_range_cd_desc, ethnic_african_american_pct,
            ethnic_asian_american_pct, ethnic_hispanic_american_pct, ethnic_native_american_pct,
            ethnic_caucasian_pct, keywords, countries_operation, language,
            donation_5, donation_10, donation_25, donation_50, donation_100,
            is_prison_school, views, donations, comment_count, favorite_count,
            share_count, mcr_net_points, status, donatable_status, mcr_status,
            payment_first_name, payment_last_name, payment_email, payment_currency,
            payment_address1, old_payment_address1, payment_address2, old_payment_address2,
            bank_routing_number, bank_account_number, iban, paypal_email,
            cached, updated, old_updated, created, cause_identifier)
    VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24,
            $25,$26,$27,$28,$29,$30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$40,$41,$42,$43,$44,$45,$46,
            $47,$48,$49,$50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$60,$61,$62,$63,$64,$65,$66,$67,$68,
            $69,$70,$71,$72,$73,$74,$75,$76,$77,$78,$79,$80,$81,$82,$83,$84,$85,$86,$87,$88,$89,$90,
            $91,$92,$93,$94,$95)')
  end

  def write(row)
    time = Time.now
    @conn.exec_prepared('insert_user_stmt',
    [
      row[:cause_id],
      row[:source_id],
      row[:source_cause_id],
      row[:mcr_school_id],
      row[:enhanced_date],
      row[:unenhanced_cause_id],
      row[:tax_id],
      row[:cause_type],
      row[:has_ach_info],
      row[:k8],
      row[:org_name],
      row[:old_org_name],
      row[:org_contact_first_name],
      row[:old_org_contact_first_name],
      row[:org_contact_last_name],
      row[:old_org_contact_last_name],
      row[:org_contact_email],
      row[:old_org_contact_email],
      row[:mcr_role],
      row[:mcr_user_level],
      row[:org_email],
      row[:org_phone],
      row[:old_org_phone],
      row[:org_fax],
      row[:mission],
      row[:additional_description],
      row[:description],
      row[:address1],
      row[:old_address1],
      row[:address2],
      row[:address3],
      row[:latitude],
      row[:longitude],
      row[:city],
      row[:old_city],
      row[:region],
      row[:old_region],
      row[:country],
      row[:postal_code],
      row[:old_postal_code],
      row[:mailing_address],
      row[:mailing_city],
      row[:mailing_state],
      row[:mailing_postal_code],
      row[:site_url],
      row[:old_site_url],
      row[:logo_url],
      row[:logo_small_url],
      row[:image_url],
      row[:video_url],
      row[:facebook_url],
      row[:newsletter_url],
      row[:photos_url],
      row[:twitter_username],
      row[:school_grades_desc],
      row[:school_student_range_cd_desc],
      row[:ethnic_african_american_pct],
      row[:ethnic_asian_american_pct],
      row[:ethnic_hispanic_american_pct],
      row[:ethnic_native_american_pct],
      row[:ethnic_caucasian_pct],
      row[:keywords],
      row[:countries_operation],
      row[:language],
      row[:donation_5],
      row[:donation_10],
      row[:donation_25],
      row[:donation_50],
      row[:donation_100],
      row[:is_prison_school],
      row[:views],
      row[:donations],
      row[:comment_count],
      row[:favorite_count],
      row[:share_count],
      row[:mcr_net_points],
      row[:status],
      row[:donatable_status],
      row[:mcr_status],
      row[:payment_first_name],
      row[:payment_last_name],
      row[:payment_email],
      row[:payment_currency],
      row[:payment_address1],
      row[:old_payment_address1],
      row[:payment_address2],
      row[:old_payment_address2],
      row[:bank_routing_number],
      row[:bank_account_number],
      row[:iban],
      row[:paypal_email],
      row[:cached],
      row[:updated],
      row[:old_updated],
      row[:created] ]
      )
      #, time
  rescue PG::Error => ex
    puts "ERROR for cause id: #{row[:cause_id]}"
    puts ex.message
    # Maybe, write to db table or file
  end

  def close
    @conn.close
    @conn = nil
  end
end
