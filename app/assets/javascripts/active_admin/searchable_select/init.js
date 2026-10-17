(function() {
  function initSearchableSelects(inputs, extra) {
    inputs.each(function() {
      var item = $(this);

      // reading from data allows <input data-searchable_select='{"tags": ['some']}'>
      // to be passed to select2
      var options = $.extend({}, extra, item.data('searchableSelect'));
      var url = item.data('ajaxUrl');

      if (url) {
        $.extend(options, {
          ajax: {
            url: url,
            dataType: 'json',

            data: function (params) {
              return $.extend({
                term: params.term,
                page: pageParamWithBaseZero(params)
              }, dependencyValues(item));
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

  function dependencies(item) {
    return item.data('searchableSelectDependsOn') || {};
  }

  function dependencyInput(item, name) {
    var form = item.closest('form');
    var input = form.find('[name="' + name + '"]').not('[type="hidden"]');
    return input.length ? input : form.find('[data-searchable-select-default-name="' + name + '"]');
  }

  function dependencyValues(item) {
    return Object.fromEntries(Object.entries(dependencies(item)).map(function(entry) {
      return [entry[0], dependencyInput(item, entry[1]).val()];
    }));
  }

  function dependsOn(item, input) {
    return Object.values(dependencies(item)).some(function(name) {
      return dependencyInput(item, name).is(input);
    });
  }

  $(document).on('change', function(event) {
    var input = event.target;

    $(input.form).find('[data-searchable-select-depends-on]').each(function() {
      var item = $(this);

      if (!dependsOn(item, input)) {
        return;
      }

      item.find('option').not('[value=""]').remove();
      item.siblings('[type="hidden"][name="' + item.attr('name') + '"]').prop('disabled', false);
      item.prop('disabled', Object.values(dependencyValues(item)).some(function(value) {
        return !(value && value.length);
      }));
      item.trigger('change');
    });
  });

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
