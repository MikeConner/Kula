function remove_kula_fee(link) {
	$(link).prev("input[type=hidden]").val("true");
	$(link).closest(".kula_fee").hide();
}
