module PartnersHelper
  def add_kula_fee(partner, form_builder)
    # Precompute the html for a new content block by calling render on the same partial used for display
    # The index is just "NEW_RECORD", since it doesn't exist yet; it will be replaced later
    # Add a link with the text "Add Payment" and the id "add_payment"
    # The inline Javascript takes the precomputed html block for a new license, replaces NEW_RECORD with a
    #  dynamically computed unique key, and inserts it in the DOM right before the link
    # Use #license elements as the unique key instead of "new Date().getTime()" so that I can predict it with RSpec
    #  
    form_builder.fields_for :kula_fees, partner.kula_fees.build, :child_index => 'NEW_RECORD' do |fee_form|
      html = render(:partial => 'kula_fee_fields', :locals => { :f => fee_form })
      onclick = "$('#{escape_javascript(html)}'.replace(/NEW_RECORD/g, $('.kula_fee').length)).insertBefore('#add_kula_fee'); return false;"
      
      content_tag(:a, 'Add Fee', :href => '#', :onclick => onclick, :id => 'add_kula_fee')
    end
  end    
end
