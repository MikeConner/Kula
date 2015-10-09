module BatchesHelper
  def add_payment(batch, form_builder)
    # Precompute the html for a new content block by calling render on the same partial used for display
    # The index is just "NEW_RECORD", since it doesn't exist yet; it will be replaced later
    # Add a link with the text "Add Payment" and the id "add_payment"
    # The inline Javascript takes the precomputed html block for a new license, replaces NEW_RECORD with a
    #  dynamically computed unique key, and inserts it in the DOM right before the link
    # Use #license elements as the unique key instead of "new Date().getTime()" so that I can predict it with RSpec
    #  
    form_builder.fields_for :payments, batch.payments.build, :child_index => 'NEW_RECORD' do |payment_form|
      html = render(:partial => 'payment', :locals => { :f => payment_form })
      onclick = "$('#{escape_javascript(html)}'.replace(/NEW_RECORD/g, $('.payment').length)).insertBefore('#add_payment'); return false;"
      
      content_tag(:a, 'Add Payment', :href => '#', :onclick => onclick, :id => 'add_payment')
    end
  end    

  def add_adjustment(batch, form_builder)
    # Precompute the html for a new content block by calling render on the same partial used for display
    # The index is just "NEW_RECORD", since it doesn't exist yet; it will be replaced later
    # Add a link with the text "Add Payment" and the id "add_payment"
    # The inline Javascript takes the precomputed html block for a new license, replaces NEW_RECORD with a
    #  dynamically computed unique key, and inserts it in the DOM right before the link
    # Use #license elements as the unique key instead of "new Date().getTime()" so that I can predict it with RSpec
    #  
    form_builder.fields_for :adjustments, batch.adjustments.build, :child_index => 'NEW_RECORD' do |adjustment_form|
      html = render(:partial => 'adjustment', :locals => { :f => adjustment_form })
      onclick = "$('#{escape_javascript(html)}'.replace(/NEW_RECORD/g, $('.adjustment').length)).insertBefore('#add_adjustment'); return false;"
      
      content_tag(:a, 'Add Adjustment', :href => '#', :onclick => onclick, :id => 'add_adjustment')
    end
  end    
end
