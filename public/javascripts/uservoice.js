var uservoiceOptions = {
  key: 'catarse',
  host: 'catarse.uservoice.com',
  forum: '103171',
  alignment: 'left',
  background_color:'#006600',
  text_color: 'white',
  hover_color: '#009900',
  lang: 'pt_BR',
  showTab: true
};
function _loadUserVoice() {
  var s = document.createElement('script');
  s.src = ("https:" == document.location.protocol ? "https://" : "http://") + "cdn.uservoice.com/javascripts/widgets/tab.js";
  document.getElementsByTagName('head')[0].appendChild(s);
}
$(document).ready(function(){
  _loadUserVoice();
});