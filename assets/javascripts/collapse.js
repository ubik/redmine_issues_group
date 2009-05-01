var $j = jQuery.noConflict();

function toggle_group(group_id) {
  el = $j('#gh-' + group_id); 
  if (!el.hasClass("open"))
  { // Show
    el.addClass('open');
    $j('tr.group-' + group_id).show();//invoke('toggle');//.hide();
    $j('tr.group-' + group_id + ' td.has-childs').addClass('open');
  } else 
  { // Hide
    el.removeClass('open');
    $j('tr.group-' + group_id).hide();//invoke('toggle');//.hide();
  }
}
function toggle_sub(group_id) {
  el = $j('tr.#issue-' + group_id + ' td.has-childs.open');
  //alert(el.length);
  if (el.length>0)
  { // Hide
    el.removeClass('open'); //invoke('toggle');//.hide();
    $j('tr.subissues-' + group_id).hide(); //invoke('toggle');//.hide();
  } else
  { // Show
    el = $j('tr.#issue-' + group_id + ' td.has-childs');
    el.addClass('open'); //invoke('toggle');//.hide();
    $j('tr.subissues-' + group_id).show(); //invoke('toggle');//.hide();
    $j('tr.subissues-' + group_id + ' td.has-childs').addClass('open');
  }
}