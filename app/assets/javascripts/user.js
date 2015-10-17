/*
 * This is for the Edit User screen, and contains logic necessary to manage roles. 
 * If you have a Cause user, they should see a dropdown of Causes; similarly, Partners should see a list of Partners. 
 * You can't have both, and if it's an Admin or SuperAdmin you can't have either -- or you will violate consistency and it won't validate
 * 
 * This hides/shows the appropriate user blocks, according to the current role
 */

$(function() { 
  if ($('#editing_user').val() != undefined ) {
    update_affiliation();
  }
  $("#autocompleted_cause").autocomplete({
    source: '/causes/autocomplete.json',
    minLength: 3
  });  
});
  
function update_affiliation() {
  var role = $('#user_role').val();

  if ("Partner" === role) {
    $('#partner_section').show();
    $('#cause_section').hide();
    $('#user_cause_id').val('');
  }
  else if ("Cause" === role) {
    $('#partner_section').hide();
    $('#cause_section').show();
    $('#user_partner_id').val('');
  }
  else {
    $('#partner_section').hide();
    $('#cause_section').hide();
    $('#user_cause_id').val('');
    $('#user_partner_id').val('');
  }
}
