$(function() { 
  jQuery('.autocompleted_cause').autocomplete({
    source: '/causes/autocomplete.json',
    minLength: 3
  });  
});
