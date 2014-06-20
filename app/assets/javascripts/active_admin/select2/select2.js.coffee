$(document).on 'has_many_add:after', '.has_many_container', (e, fieldset) ->
  fieldset.find('.select2-input').select2({allowClear: true }) 


$(document).ready ->
  $(".select2-input").select2 placeholder: "", allowClear: true
  return
