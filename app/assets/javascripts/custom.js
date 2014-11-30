$(function(){
  $( ".twitter-required" ).click(function() {
    if (!twitterConnected) {
      alert( "Please connect with Twitter to continue." );
      return false;
    }
  });

  $( ".instagram-required" ).click(function() {
    if (!instagramConnected) {
      alert( "Please connect with Instagram to continue." );
    }
  });

  $( ".google-required" ).click(function() {
    if (!googleConnected) {
      alert( "Please connect with Google to continue." );
    }
  });
});