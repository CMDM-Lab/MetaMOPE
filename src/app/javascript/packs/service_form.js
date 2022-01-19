$(function(){
    $('#mobile').on('change', function(){
            if($('#mobile').is(':checked')){
                    $('.omit').show();
            }
            else{
                    $('.omit').hide();
            }
    })

    $('#peak').on('change', function(){
            if($('#peak').is(':checked')){
                    $('.ref').show()
            }
            else{
                    $('.ref').hide()
            }
    })
});