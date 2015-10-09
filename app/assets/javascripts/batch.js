function remove_payment(link) {
	$(link).prev("input[type=hidden]").val("true");
	$(link).closest(".payment").hide();
}

function remove_adjustment(link) {
	$(link).prev("input[type=hidden]").val("true");
	$(link).closest(".adjustment").hide();
}
