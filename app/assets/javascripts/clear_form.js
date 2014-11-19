function clear_form_elements(frm) {
  $(frm).find(':input').each(function() {
    switch(this.type) {
      case 'password':
	  case 'select-multiple':
	  case 'select-one':
	  case 'text':
	  case 'textarea':
	  	$(this).val('');
		break;
	  case 'checkbox':
	  case 'radio':
	  this.checked = false;
	}
  });
}