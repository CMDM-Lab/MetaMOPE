$(function(){
    $('#is-example').on('change', function(){
        if($('#is-example').is(':checked')){
            $('.omit').hide();
        }
        else{
            $('.omit').show();
        }
    })
})