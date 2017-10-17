'use strict';

initSearchableSelects = (inputs, extra = {}) ->
  inputs.each ->
    item = $(this)
    # reading from data allows <input data-searchable_select='{"tags": ['some']}'>
    # to be passed to select2
    options = $.extend(extra, item.data('searchableSelect'))
    url = item.data('ajaxUrl');

    if url
      $.extend(
        options,
        ajax: {
          url: url,
          dataType: 'json'
        }
      )

    item.select2(options)

$(document).on 'has_many_add:after', '.has_many_container', (e, fieldset) ->
  initSearchableSelects(fieldset.find('.searchable-select-input'))

$(document).on 'page:load turbolinks:load', ->
  initSearchableSelects($(".searchable-select-input"), placeholder: "")
  return

$(-> initSearchableSelects($(".searchable-select-input")))
