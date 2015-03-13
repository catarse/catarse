$('.editable').each(function() {
    var $this = $(this);
    var styles = $this.attr('style');
    if (typeof styles != 'undefined') {
        styles = ' style="' + styles + '"';
    }

    $this.wrap('<div class="editable-wrapper"/>');
    var $w = $(this).parent();
    $w.prepend('<div style="background-color:white;" class="editable" ' + styles + ' data-placeholder="'+$this.attr('placeholder')+'">' + $this.val()+'</div>');
    $this.hide();
    var editor = new MediumEditor('.editable-wrapper', {
                                  staticToolbar: true,
                                  stickyToolbar: true,
                                  toolbarAlign: 'left',
                                  targetBlank: true,
                                  buttons:  ['bold', 'italic', 'underline', 'anchor', 'header1', 'header2', 'quote', 'unorderedlist', 'orderedlist', 'indent', 'outdent']
                                  }
                                 );
    $('.editable-wrapper').mediumInsert({
        editor: editor
    });

});

$('form').submit(function(){
    $('.editable-wrapper').each(function(){
        $(this).find('textarea').val($(this).find('.editable').html());
    });
});
