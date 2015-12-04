$(function() { 
  $(".partner_link" ).click(function() {
    var section = $(this).parent().siblings().closest('.data');
    
    if (section.is(":visible")) {
    	section.siblings().closest("i").removeClass("fa-minus").addClass("fa-plus");
    	section.hide();    	
    }
    else {
    	section.siblings().closest("i").removeClass("fa-plus").addClass("fa-minus");
    	section.show();
    }
  });
});
