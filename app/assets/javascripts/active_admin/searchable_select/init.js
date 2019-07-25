(function() {
  function initSearchableSelects(inputs, extra) {
    inputs.each(function() {
      var item = $(this);

      // reading from data allows <input data-searchable_select='{"tags": ['some']}'>
      // to be passed to select2
      var options = $.extend(extra || {}, item.data('searchableSelect'));

      // default option allow clear (must have placeholder and allowClear to options)
      if (options.placeholder == undefined)
        options.placeholder = '';

      if (options.allowClear == undefined)
        options.allowClear = true;

      var url = item.data('ajaxUrl');

      if (url) {
        $.extend(options, {
          ajax: {
            url: url,
            dataType: 'json',

            data: function (params) {
              return {
                term: params.term,
                page: pageParamWithBaseZero(params)
              };
            }
          }
        });
      }

      item.select2(options);
    });
  }

  function pageParamWithBaseZero(params) {
    return params.page ? params.page - 1 : undefined;
  }

  $(document).on('has_many_add:after', '.has_many_container', function(e, fieldset) {
    initSearchableSelects(fieldset.find('.searchable-select-input'));
  });

  $(document).on('page:load turbolinks:load', function() {
    initSearchableSelects($(".searchable-select-input"), {placeholder: ""});
  });

  $(function() {
    initSearchableSelects($(".searchable-select-input"));
  });
}());
