$(document).ready(function() {

    $(".on_the_spot_editing").mouseover(function() {
        $(this).addClass('on_the_spot_mouseover');
    });
    $(".on_the_spot_editing").mouseout(function() {
        $(this).removeClass('on_the_spot_mouseover');
    });
    $(".on_the_spot_editing").click(function() {
        $(this).addClass('on_the_spot_form')
    });
    $('.on_the_spot_editing').each(function(n){
        var el           = $(this),
            data_url     = el.attr('data-url'),
            ok_text      = el.attr('data-ok') || 'OK',
            cancel_text  = el.attr('data-cancel') || 'Cancel',
            tooltip_text = el.attr('data-tooltip') || 'Click to edit ...',
            placeholder_text = el.attr('data-tooltip') || 'Click to edit ...',
            edit_type    = el.attr('data-edittype'),
            select_data  = el.attr('data-select'),
            rows         = el.attr('data-rows'),
            columns      = el.attr('data-columns'),
            load_url     = el.attr('data-loadurl');

        var options = {
            tooltip: tooltip_text,
            placeholder: placeholder_text,
            cancel: cancel_text,
            submit: ok_text,
            onerror: function (settings, original, xhr) {
                original.reset();
                //just show the error-msg for now
                alert(xhr.responseText);
            },
            onreset: function(){
              $(this).parent().removeClass('on_the_spot_form')
            }
        };
        if (edit_type != null) {
            options.type = edit_type;
        }
        if (edit_type == 'select') {
            if (select_data != null) {
                options.data = select_data;
                options.submitdata = { 'select_array': select_data }
            }
            if (load_url != null) {
                options.loadurl = load_url;
            }
        }
        else if (edit_type == 'textarea') {
            options.rows = rows;
            options.cols = columns;
        }
        el.editable(data_url, options)
    })

});