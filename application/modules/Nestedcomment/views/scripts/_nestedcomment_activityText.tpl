<?php
/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Nestedcomment
 * @copyright  Copyright 2014-2015 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: _nestedcomment_activityText.tpl 6590 2014-11-07 00:00:00Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
?>

<?php 
  include_once APPLICATION_PATH . '/application/modules/Nestedcomment/views/scripts/_activitySettings.tpl';
?>
<?php $sharesTable = Engine_Api::_()->getDbtable('shares', 'advancedactivity'); ?>
<?php

if (empty($this->actions)) {
    echo $this->translate("The action you are looking for does not exist.");
    return;
} else {
    $actions = $this->actions;
}
?>

<script type="text/javascript">
  var CommentLikesTooltips;
  var ComposerNestedActivityComment;
  var hideItemFeeds;
  var unhideItemFeed;
  var moreEditOptionsSwitch;
  var unhideReqActive = false;
  var el_siteevent;
  var photoEnabled = '<?php echo $photoEnabled ?>';
  var smiliesEnabled = '<?php echo $smiliesEnabled ?>';
  var activityTaggingContent = '<?php echo $activityTaggingContent;?>';
  var allowQuickComment = '<?php echo ($this->isMobile || !$this->commentShowBottomPost || Engine_Api::_()->getApi('settings', 'core')->core_spam_comment) ? 0 : 1; ?>';
  var allowQuickReply = '<?php echo ($this->isMobile || !$this->commentShowBottomPost || Engine_Api::_()->getApi('settings', 'core')->core_spam_comment) ? 0 : 1; ?>';
  <?php if(Engine_Api::_()->getDbtable('modules', 'core')->isModuleEnabled('sitealbum') && Engine_Api::_()->nestedcomment()->checkVersion(Engine_Api::_()->getDbtable('modules', 'core')->getModule('sitealbum')->version, '4.8.4')): ?>
			var requestOptionsURLNestedComment = en4.core.baseUrl + 'sitealbum/album/compose-upload/type/comment';
			var fancyUploadOptionsURLNestedComment = en4.core.baseUrl + 'sitealbum/album/compose-upload/format/json/type/comment';
    <?php else: ?>
			var requestOptionsURLNestedComment = en4.core.baseUrl + 'nestedcomment/album/compose-upload/type/comment';
			var fancyUploadOptionsURLNestedComment = en4.core.baseUrl + 'nestedcomment/album/compose-upload/format/json/type/comment';
    <?php endif; ?>
  en4.core.runonce.add(function() {
    en4.core.language.addData({
      "Stories from %s are hidden now and will not appear in your Activity Feed anymore.": "<?php echo $this->string()->escapeJavascript($this->translate("Stories from %s are hidden now and will not appear in your Activity Feed anymore.")); ?>"
    });
    // Add hover event to get likes
    $$('.comments_comment_likes').addEvent('mouseover', function(event) {
      var el = $(event.target);
      if (!el.retrieve('tip-loaded', false)) {
        el.store('tip-loaded', true);
        el.store('tip:title', '<?php echo $this->string()->escapeJavascript($this->translate('Loading...')) ?>');
        el.store('tip:text', '');
        var id = el.get('id').match(/\d+/)[0];
        // Load the likes
        var url = '<?php echo $this->url(array('module' => 'advancedactivity', 'controller' => 'index', 'action' => 'get-likes'), 'default', true) ?>';
        var req = new Request.JSON({
          url: url,
          data: {
            format: 'json',
            //type : 'core_comment',
            action_id: el.getParent('li').getParent('li').getParent('li').get('id').match(/\d+/)[0],
            comment_id: id
          },
          onComplete: function(responseJSON) {
            el.store('tip:title', responseJSON.body);
            el.store('tip:text', '');
            CommentLikesTooltips.elementEnter(event, el); // Force it to update the text

          }
        });
        req.send();
      }
    });
    // Add tooltips
    CommentLikesTooltips = new Tips($$('.comments_comment_likes'), {
      fixed: true,
      className: 'comments_comment_likes_tips',
      offset: {
        'x': 20,
        'y': 10
      }
    });
    // Enable links in comments
    $$('.comments_body').enableLinks();
    $$('.feed_item_body_content').enableLinks();
    if (feedToolTipAAFEnable) {
      // Add hover event to get tool-tip
      var show_tool_tip = false;
      var counter_req_pendding = 0;
      $$('.sea_add_tooltip_link').addEvent('mouseover', function(event) {
        var el = $(event.target);
        el_siteevent = el;
        ItemTooltips.options.offset.y = el.offsetHeight;
        ItemTooltips.options.showDelay = 0;
        if (!el.get('rel')) {
          el = el.parentNode;
        }
        if (el && !el.retrieve('tip-loaded', false)) {
          el.store('tip:title', '');
          el.store('tip:text', '');
        }
        if (el.getParent('.layout_advancedactivitypost_feed_short'))
          return;
        show_tool_tip = true;
        if (!el.retrieve('tip-loaded', false)) {
          counter_req_pendding++;
          var resource = '';
          if (el.get('rel'))
            resource = el.get('rel');
          if (resource == '')
            return;

          el.store('tip-loaded', true);
          el.store('tip:title', '<div class="" style="">' +
                  ' <div class="uiOverlay info_tip" style="width: 300px; top: 0px; ">' +
                  '<div class="info_tip_content_wrapper" ><div class="info_tip_content"><div class="info_tip_content_loader">' +
                  '<img src="<?php echo $this->layout()->staticBaseUrl ?>application/modules/Core/externals/images/loading.gif" alt="Loading" /><?php echo $this->translate("Loading ...") ?></div>' +
                  '</div></div></div></div>'
                  );
          el.store('tip:text', '');
          // Load the likes
          var url = '<?php echo $this->url(array('module' => 'seaocore', 'controller' => 'feed', 'action' => 'show-tooltip-info'), 'default', true) ?>';
          el.addEvent('mouseleave', function() {
            show_tool_tip = false;
          });

          var req = new Request.HTML({
            url: url,
            data: {
              format: 'html',
              'resource': resource
            },
            evalScripts: true,
            onSuccess: function(responseTree, responseElements, responseHTML, responseJavaScript) {
              el.store('tip:title', '');
              el.store('tip:text', responseHTML);
              ItemTooltips.options.showDelay = 0;
              ItemTooltips.elementEnter(event, el); // Force it to update the text 
              counter_req_pendding--;
              if (!show_tool_tip || counter_req_pendding > 0) {
                //ItemTooltips.hide(el);
                ItemTooltips.elementLeave(event, el);
              }
              var tipEl = ItemTooltips.toElement();
              tipEl.addEvents({
                'mouseenter': function() {
                  ItemTooltips.options.canHide = false;
                  ItemTooltips.show(el);
                },
                'mouseleave': function() {
                  ItemTooltips.options.canHide = true;
                  ItemTooltips.hide(el);
                }
              });
              Smoothbox.bind($$(".sea_add_tooltip_link_tips"));

            }
          });
          req.send();
        }
      });
      // Add tooltips
      var window_size = window.getSize()
      var ItemTooltips = new SEATips($$('.sea_add_tooltip_link'), {
        fixed: true,
        title: '',
        className: 'sea_add_tooltip_link_tips',
        hideDelay: 200,
        offset: {'x': 0, 'y': 0},
        windowPadding: {'x': 370, 'y': (window_size.y / 2)}
      }
      );
    }
<?php if ($this->viewer()->getIdentity()): ?>
      hideItemFeeds = function(type, id, parent_type, parent_id, parent_html, report_url) {
        if (en4.core.request.isRequestActive())
          return;
        var url = '<?php echo $this->url(array('module' => 'advancedactivity', 'controller' => 'feed', 'action' => 'hide-item'), 'default', true); ?>';
        var req = new Request.JSON({
          url: url,
          data: {
            format: 'json',
            type: type,
            id: id
          },
          onComplete: function(responseJSON) {

            if (type == 'activity_action' && $('activity-item-' + id)) {

              if ($('activity-item-undo-' + id))
                $('activity-item-undo-' + id).destroy();
              $('activity-item-' + id).style.display = 'none';
              var innerHTML = "<li id='activity-item-undo-" + id + "'><div class='feed_item_hide'>"
                      + "<b><?php echo $this->string()->escapeJavascript($this->translate("This story is now hidden from your Activity Feed.")) ?></b>" + " <a href='javascript:void(0);' onclick='unhideItemFeed(\"" + type + "\" , \"" + id + "\")'>" + "<?php echo $this->string()->escapeJavascript($this->translate("Undo")) ?> </a> <br /> ";
              if (report_url == '') {
                innerHTML = innerHTML + "<span> <a href='javascript:void(0);' onclick='hideItemFeeds(\"" + parent_type + "\" , \"" + parent_id + "\",\"\",\"" + id + "\", \"" + parent_html + "\",\"\")'>"
                        + '<?php
  echo
  $this->string()->escapeJavascript($this->translate('Hide all by '));
  ?>' + parent_html + "</a></span>";
              } else {
                innerHTML = innerHTML + "<span> <?php echo $this->string()->escapeJavascript($this->translate("To mark it offensive, please ")) ?> <a href='javascript:void(0);' onclick='Smoothbox.open(\"" + report_url + "\")'>" + "<?php echo $this->string()->escapeJavascript($this->translate("file a report")) ?>" + "</a>" + "<?php echo '.' ?>" + "</span>";
              }

              innerHTML = innerHTML + "</div></li>";
              Elements.from(innerHTML).inject($('activity-item-' + id), 'after');

            } else {
              if ($('activity-item-undo-' + parent_id))
                $('activity-item-undo-' + parent_id).destroy();
              var innerHTML = "<li id='activity-item-undo-" + id + "'><b>" + en4.core.language.translate("Stories from %s are hidden now and will not appear in your Activity Feed anymore.", parent_html) + "</b> <a href='javascript:void(0);' onclick='unhideItemFeed(\"" + type + "\" , \"" + id + "\")'>" + "<?php echo $this->string()->escapeJavascript($this->translate("Undo")) ?> </a>" + "</li>";
              Elements.from(innerHTML).inject($('activity-item-' + parent_id), 'after');

              var className = '.Hide_' + type + '_' + id;
              var myElements = $$(className);
              for (var i = 0; i < myElements.length; i++) {
                myElements[i].style.display = 'none';
              }
            }
          }
        });
        req.send();
      }

      unhideItemFeed = function(type, id) {
        if (unhideReqActive)
          return;
        unhideReqActive = true;
        var url = '<?php echo $this->url(array('module' => 'advancedactivity', 'controller' => 'feed', 'action' => 'un-hide-item'), 'default', true); ?>';
        var req = new Request.JSON({
          url: url,
          data: {
            format: 'json',
            type: type,
            id: id
          },
          onComplete: function(responseJSON) {
            if ($('activity-item-undo-' + id))
              $('activity-item-undo-' + id).destroy();
            if (type == 'activity_action' && $('activity-item-' + id)) {

              $('activity-item-' + id).style.display = '';
              //document.getElementById('activity-feed').removeChild($('activity-item-undo-'+id));
            } else {
              var className = '.Hide_' + type + '_' + id;
              var myElements = $$(className);
              for (var i = 0; i < myElements.length; i++) {
                myElements[i].style.display = '';
              }
              //  document.getElementById('activity-feed').removeChild($('activity-item-undo-'+id));
            }
            unhideReqActive = false;
          }
        });
        req.send();
      }

  <?php if (!$this->feedOnly && !$this->onlyactivity): ?>
        moreEditOptionsSwitch = function(el) {
          moreADVHideEventEnable = true;
          var hideElements = $$('.aaf_pulldown_btn_wrapper');
          for (var i = 0; i < hideElements.length; i++) {
            if (hideElements[i] != el)
              hideElements[i].removeClass('aaf_tabs_feed_tab_open').addClass('aaf_tabs_feed_tab_closed');
          }
          el.toggleClass('aaf_tabs_feed_tab_open');
          el.toggleClass('aaf_tabs_feed_tab_closed');

        }
  <?php endif; ?>
<?php endif; ?>

    if (en4.sitevideoview) {
      en4.sitevideoview.attachClickEvent(Array('feed', 'feed_video_title', 'feed_sitepagevideo_title', 'feed_sitebusinessvideo_title', 'feed_ynvideo_title', 'feed_sitegroupvideo_title', 'feed_sitestorevideo_title'));
    }
    
     if (en4.sitevideolightboxview) {
      en4.sitevideolightboxview.attachClickEvent(Array('feed', 'feed_video_title', 'feed_sitepagevideo_title', 'feed_sitebusinessvideo_title', 'feed_ynvideo_title', 'feed_sitegroupvideo_title', 'feed_sitestorevideo_title', 'sitevideo_thumb_viewer'));
    }
  });
</script>
<?php if (!$this->feedOnly && !$this->onlyactivity): ?>
  <ul class='feed' id="activity-feed">
  <?php endif ?>
  <?php
  $advancedactivityCoreApi = Engine_Api::_()->advancedactivity();
  $advancedactivitySaveFeed = Engine_Api::_()->getDbtable('saveFeeds', 'advancedactivity');
  ?>
  <?php
  foreach ($actions as $action): // (goes to the end of the file)
    try { // prevents a bad feed item from destroying the entire page
      // Moved to controller, but the items are kept in memory, so it shouldn't hurt to double-check
      if (!$action->getTypeInfo()->enabled)
        continue;
      if (!$action->getSubject() || !$action->getSubject()->getIdentity())
        continue;
      if (!$action->getObject() || !$action->getObject()->getIdentity())
        continue;
      ob_start();
      if (!$this->noList && !$this->subject() && $action->getTypeInfo()->type == 'birthday_post'):
        echo $this->birthdayActivityLoop($action, array(
            'action_id' => $this->action_id,
            'viewAllComments' => $this->viewAllComments,
            'viewAllLikes' => $this->viewAllLikes,
            'commentShowBottomPost' => $this->commentShowBottomPost
        ));
        ob_end_flush();
        continue;
      endif;
      ?>

      <?php
      $item = $itemPhoto = (isset($action->getTypeInfo()->is_object_thumb) && !empty($action->getTypeInfo()->is_object_thumb)) ? $action->getObject() : $action->getSubject();
      $itemPhoto = (isset($action->getTypeInfo()->is_object_thumb) && $action->getTypeInfo()->is_object_thumb === 2) ? $action->getObject()->getParent() : $itemPhoto;
      ?>
      <?php if (!$this->noList): ?><li class="activity-item <?php echo 'Hide_' . $item->getType() . "_" . $item->getIdentity() ?>" id="activity-item-<?php echo $action->action_id ?>"  data-activity-feed-item="<?php echo $action->action_id ?>" <?php if ($this->onViewPage): ?>style="padding-bottom: 30px;" <?php endif; ?> ><?php endif; ?>
      <?php
      if ($this->onViewPage): $actionBaseId = "view-" . $action->action_id;
      else:$actionBaseId = $action->action_id;
      endif;
      ?>
      <?php
      $this->commentForm->setActionIdentity($actionBaseId);
      $this->commentForm->action_id->setValue($action->action_id);
      ?>
      
        <script type="text/javascript">
          (function() {
            
            en4.core.runonce.add(function()  { 

    <?php if ($this->onViewPage): ?>
                (function() {
    <?php endif; ?>
                if (!$('<?php echo $this->commentForm->body->getAttrib('id') ?>'))
                  return;
                $('<?php echo $this->commentForm->body->getAttrib('id') ?>').autogrow();
                
                //en4.nestedcomment.nestedcomments.attachComment($('<?php echo $this->commentForm->getAttrib('id') ?>'), allowQuickComment);
                

                if (allowQuickComment == '1' && <?php echo $this->submitComment ? '1' : '0' ?>) {
                  document.getElementById("<?php echo $this->commentForm->getAttrib('id') ?>").style.display = "";
                  document.getElementById("<?php echo $this->commentForm->submit->getAttrib('id') ?>").style.display = "none";
                  if (document.getElementById("feed-comment-form-open-li_<?php echo $actionBaseId ?>")) {
                    document.getElementById("feed-comment-form-open-li_<?php echo $actionBaseId ?>").style.display = "none";
                  }
                  document.getElementById("<?php echo $this->commentForm->body->getAttrib('id') ?>").focus();
                }
    <?php if ($this->onViewPage): ?>
                }).delay(1000);
    <?php endif; ?>
            });
          })();
        </script>   
        <?php // User's profile photo ?>
        <div class='feed_item_photo'> <?php
          echo $this->htmlLink($itemPhoto->getHref(), $this->itemPhoto($itemPhoto, 'thumb.icon', $itemPhoto->getTitle()), array('class' => 'sea_add_tooltip_link', 'rel' => $itemPhoto->getType() . ' ' . $itemPhoto->getIdentity())
          )
          ?></div>

        <?php
        $privacy_icon_class = null;
        $privacy_titile = null;
        $privacy_titile_array = array();
        ?>
        <?php $allowEdit = $this->viewer()->getIdentity() && in_array($action->getTypeInfo()->type, array("post", "post_self", "share", "status", 'sitetagcheckin_status', 'sitetagcheckin_post_self', 'sitetagcheckin_post','post_self_photo','post_self_video','post_self_music','post_self_link', 'sitegroup_post', 'sitepage_post', 'sitebusiness_post', 'sitegroup_post_self', 'siteevent_post', 'siteevent_post_parent','sitebusiness_post_self', 'sitepage_post_self'))  && (('user' == $action->subject_type && $this->viewer()->getIdentity() == $action->subject_id)); ?>
        <?php if (!$this->subject() && $this->viewer()->getIdentity() && $action->getTypeInfo()->type != 'birthday_post' && (!$this->viewer()->isSelf($action->getSubject()))): ?>
          <span class="aaf_tabs_feed_tab_closed aaf_pulldown_btn_wrapper" onclick="moreEditOptionsSwitch($(this));">
            <div class="aaf_pulldown_contents_wrapper">
              <div class="aaf_pulldown_contents">
                <ul>
                  <?php if (!$this->subject()): ?>
                    <?php if ($this->allowSaveFeed): ?>
                      <li class="feed_item_option_delete">              
                        <a href="javascript:void(0);" title="" onclick="en4.advancedactivity.updateSaveFeed('<?php echo $action->action_id ?>')">
                          <?php echo $this->translate(($advancedactivitySaveFeed->getSaveFeed($this->viewer(), $action->action_id)) ? 'Unsaved Feed' : 'Save Feed') ?></a>
                      </li>
                    <?php endif; ?>
                    <li>
                      <a href="javascript:void(0);" onclick='showLinkPost("<?php echo $item->getHref(array('action_id' => $action->action_id, 'show_comments' => true)) ?>")'><?php echo $this->translate('Feed Link'); ?></a>
                    </li>
                    <li class="sep"></li>
                    <li>
                      <a href="javascript:void(0);" onclick='hideItemFeeds("<?php echo $action->getType() ?>", "<?php
                      echo
                      $action->getIdentity()
                      ?>", "<?php echo $item->getType() ?>", "<?php echo $item->getIdentity() ?>", "<?php echo $this->string()->escapeJavascript(html_entity_decode($item->getTitle())); ?>", "");' ><?php
                           echo
                           $this->translate('Hide');
                           ?></a>
                    </li>
                  <?php endif; ?>
                  <li>
                    <a href="javascript:void(0);" onclick='hideItemFeeds("<?php echo $action->getType() ?>", "<?php
                    echo
                    $action->getIdentity()
                    ?>", "<?php echo $item->getType() ?>", "<?php echo $item->getIdentity() ?>", "<?php
                    echo
                    $this->string()->escapeJavascript(html_entity_decode($item->getTitle()));
                    ?>", "<?php
                    echo $this->url(array('module' => 'advancedactivity', 'controller' => 'report', 'action' => 'create', 'subject' =>
                        $action->getGuid(), 'format' => 'smoothbox'), 'default', true);
                    ?>");'><?php echo $this->translate('Report Feed'); ?></a>
                  </li>
                  <?php if (!$this->subject()): ?>              
                    <li class="sep"></li>
                    <li>
                      <a href="javascript:void(0);" onclick='hideItemFeeds("<?php echo $item->getType() ?>", "<?php echo $item->getIdentity() ?>", "", "<?php echo $action->getIdentity() ?>", "<?php echo $this->string()->escapeJavascript(html_entity_decode($item->getTitle())); ?>", "");' ><?php echo $this->translate('Hide all by %s', $item->getTitle()); ?></a>
                    </li>
                  <?php endif; ?>
                  <?php
                  if ($this->viewer()->getIdentity() && (
                          $this->activity_moderate || $this->is_owner || (
                          $this->allow_delete && (
                          ('user' == $action->subject_type && $this->viewer()->getIdentity() == $action->subject_id) ||
                          ('user' == $action->object_type && $this->viewer()->getIdentity() == $action->object_id)
                          )
                          )
                          )):
                    ?>
                    <li class="sep"></li>
                    <?php if ($allowEdit): ?>
                    <li class="feed_item_option_edit">
                        <a href="javascript:void(0);"><?php echo $this->translate('Edit Feed') ?></a>
                    </li>
                    <?php endif; ?>
                    <li class="feed_item_option_delete">
                      <a href="javascript:void(0);" title="" onclick="deletefeed('<?php
                      echo
                      $action->action_id
                      ?>', '0', '<?php
                      echo
                      $this->escape($this->url(array('route' => 'default',
                                  'module' => 'advancedactivity', 'controller' => 'index', 'action' => 'delete')))
                      ?>')"><?php
                           echo
                           $this->translate('Delete Feed')
                           ?></a>
                    </li>
                    <?php if ($action->getTypeInfo()->commentable): ?>
                      <li class="feed_item_option_delete">              
                        <a href="javascript:void(0);" title="" onclick="en4.advancedactivity.updateCommentable('<?php echo $action->action_id ?>')">
                          <?php echo $this->translate(($action->commentable) ? 'Disable Comments' : 'Enable Comments') ?></a>
                      </li>
                    <?php endif; ?>              
                    <?php if ($action->getTypeInfo()->shareable > 1 || ($action->getTypeInfo()->shareable == 1 && $action->attachment_count == 1 && ($attachment = $action->getFirstAttachment()))): ?>
                      <li class="feed_item_option_delete">            
                        <a href="javascript:void(0);" title="" onclick="en4.advancedactivity.updateShareable('<?php echo $action->action_id ?>')">
                          <?php echo $this->translate(($action->shareable) ? 'Lock this Feed' : 'Unlock this Feed') ?></a>
                      </li>
                    <?php endif; ?>
                  <?php endif; ?>
                </ul>
              </div>
            </div>
            <span class="aaf_pulldown_btn"></span>
          </span> 
        <?php elseif ($this->allowEdit && !empty($action->privacy) && in_array($action->getTypeInfo()->type, array("post", "post_self", "status", 'sitetagcheckin_add_to_map', 'sitetagcheckin_content', 'sitetagcheckin_status', 'sitetagcheckin_post_self', 'sitetagcheckin_post', 'sitetagcheckin_checkin', 'sitetagcheckin_lct_add_to_map','post_self_photo','post_self_video','post_self_music','post_self_link')) && $this->viewer()->getIdentity() && (('user' == $action->subject_type && $this->viewer()->getIdentity() == $action->subject_id))): ?>
          <span class="aaf_tabs_feed_tab_closed aaf_pulldown_btn_wrapper" onclick="moreEditOptionsSwitch($(this));">
            <div class="aaf_pulldown_contents_wrapper">
              <div class="aaf_pulldown_contents">
                <ul>
                  <?php $privacy = $action->privacy ?>
                  <?php foreach ($this->privacyDropdownList as $key => $value): ?>
                    <?php if ($value == "separator"): ?>
                      <li class="sep"></li>
                    <?php elseif ($key == 'network_custom'): ?>
                      <li onclick="editPostStatusPrivacy('<?php echo $action->getIdentity() ?>', '<?php echo $key ?>')"
                          class="aaf_custom_list" title="<?php echo $this->translate("Choose multiple Networks to share with.");
                      ?>"><i class="aaf_privacy_pulldown_icon aaf_icon_feed_custom"></i>
                        <div><?php echo $this->translate($value); ?></div></li>
                    <?php elseif (strpos($key, "custom") !== false): ?>
                      <li onclick="editPostStatusPrivacy('<?php echo $action->getIdentity() ?>', '<?php echo $key ?>')"
                          class="aaf_custom_list" title="<?php echo $this->translate("Choose multiple Friend Lists to share with.");
                      ?>"><i class="aaf_privacy_pulldown_icon aaf_icon_feed_custom"></i>
                        <div><?php echo $this->translate($value); ?></div></li>
                    <?php elseif (in_array($key, array("everyone", "networks", "friends", "onlyme"))): ?>
                      <?php
                      if ($key == $privacy):
                        $privacy_icon_class = "aaf_icon_feed_" . $key;
                        $privacy_titile = $value;
                      endif;
                      ?>
                      <li class="<?php echo ( $key == $privacy ? 'aaf_tab_active' : 'aaf_tab_unactive' ) ?> user_profile_friend_list_<?php echo $key ?> aaf_custom_list" id="privacy_list_<?php echo $key ?>" onclick="editPostStatusPrivacy('<?php echo $action->getIdentity() ?>', '<?php echo $key ?>')" title="<?php echo $this->translate("Share with %s", $this->translate($value)); ?>" >
                        <i class="aaf_privacy_pulldown_icon aaf_icon_feed_<?php echo $key ?>"></i>             
                        <div><?php echo $this->translate($value); ?></div>
                      </li>
                    <?php else: ?>
                      <?php
                      if ((in_array($key, explode(",", $privacy)))):
                        $privacy_titile_array[] = $value;
                      endif;
                      ?>
                      <li class="<?php echo ( (in_array($key, explode(",", $privacy))) ? 'aaf_tab_active' : 'aaf_tab_unactive' ) ?> user_profile_friend_list_<?php echo $key ?> aaf_custom_list" id="privacy_list_<?php echo $key ?>" onclick="editPostStatusPrivacy('<?php echo $action->getIdentity() ?>', '<?php echo $key ?>')" title="<?php echo $this->translate("Share with %s", $value); ?>">
                        <i class="aaf_privacy_pulldown_icon <?php echo strpos($key, "network_") !== false ? "aaf_icon_feed_network_list" : "aaf_icon_feed_list" ?>"></i>                         
                        <div><?php echo $this->translate($value) ?></div>
                      </li>
                    <?php endif; ?>
                  <?php endforeach; ?>
                  <?php
                  if (!empty($privacy_titile_array)):
                    $privacy_titile = join(", ", $privacy_titile_array);
                    if (Engine_Api::_()->advancedactivity()->isNetworkBasePrivacy($privacy)):
                      $privacy_icon_class = (count($privacy_titile_array) > 1) ? "aaf_icon_feed_custom" : "aaf_icon_feed_network_list";
                    else:
                      $privacy_icon_class = (count($privacy_titile_array) > 1) ? "aaf_icon_feed_custom" : "aaf_icon_feed_list";
                    endif;
                  endif;
                  ?>
                  <li class="sep"></li>
                  <?php if ($this->allowSaveFeed): ?>
                    <li class="feed_item_option_delete">              
                      <a href="javascript:void(0);" title="" onclick="en4.advancedactivity.updateSaveFeed('<?php echo $action->action_id ?>')">
                        <?php echo $this->translate(($advancedactivitySaveFeed->getSaveFeed($this->viewer(), $action->action_id)) ? 'Unsaved Feed' : 'Save Feed') ?></a>
                    </li>
                  <?php endif; ?>
                  <li>
                    <a href="javascript:void(0);" onclick='showLinkPost("<?php echo $action->getSubject()->getHref(array('action_id' => $action->action_id, 'show_comments' => true)) ?>")'><?php echo $this->translate('Feed Link'); ?></a>
                  </li>
                  <?php if ($this->activity_moderate || $this->allow_delete || $this->is_owner): ?>
                    <li class="sep"></li>
                    <?php if ($allowEdit): ?>
                    <li class="feed_item_option_edit">
                        <a href="javascript:void(0);"><?php echo $this->translate('Edit Feed') ?></a>
                    </li>
                    <?php endif; ?>
                    <li class="feed_item_option_delete">
                      <a href="javascript:void(0);" title="" onclick="deletefeed('<?php echo $action->action_id ?>', '0', '<?php echo $this->escape($this->url(array('route' => 'default', 'module' => 'advancedactivity', 'controller' => 'index', 'action' => 'delete'))) ?>')"><?php echo $this->translate('Delete Feed') ?></a>
                    </li>
                    <?php if ($this->allowEditCategory && in_array($action->getTypeInfo()->type, array("post", "post_self", "status")) && $this->viewer()->getIdentity() && (('user' == $action->object_type && $this->viewer()->getIdentity() == $action->object_id))): ?>
                      <li class="feed_item_option_delete">              
                        <?php
                        echo $this->htmlLink(array(
                            'route' => 'default',
                            'module' => 'advancedactivitypost',
                            'controller' => 'index',
                            'action' => 'edit-category',
                            'action_id' => $action->action_id
                                ), $this->translate('Edit Category'), array('class' => 'smoothbox'))
                        ?>
                      </li>
                    <?php endif; ?>
                    <?php if ($action->getTypeInfo()->commentable): ?>
                      <li class="feed_item_option_delete">              
                        <a href="javascript:void(0);" title="" onclick="en4.advancedactivity.updateCommentable('<?php echo $action->action_id ?>')">
                          <?php echo $this->translate(($action->commentable) ? 'Disable Comments' : 'Enable Comments') ?></a>
                      </li>
                    <?php endif; ?>
                    <?php if ($action->getTypeInfo()->shareable > 1 || ($action->getTypeInfo()->shareable == 1 && $action->attachment_count == 1 && ($attachment = $action->getFirstAttachment()))): ?>
                      <li class="feed_item_option_delete">            
                        <a href="javascript:void(0);" title="" onclick="en4.advancedactivity.updateShareable('<?php echo $action->action_id ?>')">
                          <?php echo $this->translate(($action->shareable) ? 'Lock this Feed' : 'Unlock this Feed') ?></a>
                      </li>
                    <?php endif; ?>
                  <?php endif; ?>
                </ul>
              </div>
            </div>
            <span class="aaf_pulldown_btn"></span>
          </span> 
        <?php else: ?>
          <?php
          if ($this->viewer()->getIdentity() && (
                  $this->activity_moderate || $this->is_owner || (
                  $this->allow_delete && (
                  ('user' == $action->subject_type && $this->viewer()->getIdentity() == $action->subject_id) ||
                  ('user' == $action->object_type && $this->viewer()->getIdentity() == $action->object_id)
                  )
                  )
                  )):
            ?>
            <span class="aaf_tabs_feed_tab_closed aaf_pulldown_btn_wrapper" onclick="moreEditOptionsSwitch($(this));">
              <div class="aaf_pulldown_contents_wrapper">
                <div class="aaf_pulldown_contents">
                  <ul>
                    <?php if ($this->allowSaveFeed): ?>
                      <li class="feed_item_option_delete">              
                        <a href="javascript:void(0);" title="" onclick="en4.advancedactivity.updateSaveFeed('<?php echo $action->action_id ?>')">
                          <?php echo $this->translate(($advancedactivitySaveFeed->getSaveFeed($this->viewer(), $action->action_id)) ? 'Unsaved Feed' : 'Save Feed') ?></a>
                      </li>
                    <?php endif; ?>
                    <li>
                      <a href="javascript:void(0);" onclick='showLinkPost("<?php echo $action->getSubject()->getHref(array('action_id' => $action->action_id, 'show_comments' => true)) ?>")'><?php echo $this->translate('Feed Link'); ?></a>
                    </li>
                    <li class="sep"></li>
                    <?php if ($allowEdit): ?>
                    <li class="feed_item_option_edit">
                        <a href="javascript:void(0);"><?php echo $this->translate('Edit Feed') ?></a>
                    </li>
                    <?php endif; ?>
                    <li class="feed_item_option_delete">
                      <a href="javascript:void(0);" title="" onclick="deletefeed('<?php echo $action->action_id ?>', '0', '<?php echo $this->escape($this->url(array('route' => 'default', 'module' => 'advancedactivity', 'controller' => 'index', 'action' => 'delete'))) ?>')"><?php echo $this->translate('Delete Feed') ?></a>
                    </li>
                    <?php if ($this->allowEditCategory && in_array($action->getTypeInfo()->type, array("post", "post_self", "status")) && $this->viewer()->getIdentity() && (('user' == $action->object_type && $this->viewer()->getIdentity() == $action->object_id))): ?>
                      <li class="feed_item_option_delete">              
                        <?php
                        echo $this->htmlLink(array(
                            'route' => 'default',
                            'module' => 'advancedactivitypost',
                            'controller' => 'index',
                            'action' => 'edit-category',
                            'action_id' => $action->action_id
                                ), $this->translate('Edit Category'), array('class' => 'smoothbox'))
                        ?>
                      </li>
                    <?php endif; ?>
                    <?php if ($action->getTypeInfo()->commentable): ?>
                      <li class="feed_item_option_delete">              
                        <a href="javascript:void(0);" title="" onclick="en4.advancedactivity.updateCommentable('<?php echo $action->action_id ?>')">
                          <?php echo $this->translate(($action->commentable) ? 'Disable Comments' : 'Enable Comments') ?></a>
                      </li>
                    <?php endif; ?>
                    <?php if ($action->getTypeInfo()->shareable > 1 || ($action->getTypeInfo()->shareable == 1 && $action->attachment_count == 1 && ($attachment = $action->getFirstAttachment()))): ?>
                      <li class="feed_item_option_delete">            
                        <a href="javascript:void(0);" title="" onclick="en4.advancedactivity.updateShareable('<?php echo $action->action_id ?>')">
                          <?php echo $this->translate(($action->shareable) ? 'Lock this Feed' : 'Unlock this Feed') ?></a>
                      </li>
                    <?php endif; ?>
                  </ul>
                </div>
              </div>
              <span class="aaf_pulldown_btn"></span>
            </span>
          <?php endif; ?>
        <?php endif; ?>
        <div class='feed_item_body'>
          <?php // Main Content  ?>

          <span class="feed_item_body_content  <?php echo ( empty($action->getTypeInfo()->is_generated) ? 'feed_item_posted' : 'feed_item_generated' ) ?>">

            <?php
            /* Start Working group feed. */
            $groupedFeeds = null;
            if ($action->type == 'friends') {
              $subject_guid = $action->getSubject()->getGuid();
              $total_guid = $action->type . '_' . $subject_guid;
            } elseif ($action && $action->type == 'tagged' && $action->getAttachments()) {
              foreach ($action->getAttachments() as $attachment) {
                $object_guid = $attachment->item->getGuid();
                $Subject_guid = $action->getSubject()->getGuid();
                $total_guid = $action->type . '_' . $object_guid . '_' . $Subject_guid;
              }
            } else {
              $subject_guid = $action->getObject()->getGuid();
              $total_guid = $action->type . '_' . $subject_guid;
            }

            if (!isset($grouped_actions[$total_guid]) && isset($this->groupedFeeds[$total_guid])) {
              $groupedFeeds = $this->groupedFeeds[$total_guid];
            }
            /* End Working group feed. */
            ?>
            <?php echo $this->getContent($action, false, $groupedFeeds); ?>
          </span>
          <?php echo $allowEdit ? $this->editPost($action): '';?>
          <?php // Attachments ?>
          <?php if ($action->getTypeInfo()->attachable && $action->attachment_count > 0): // Attachments  ?>
            <div class='feed_item_attachments <?php echo (count($action->getAttachments()) != 1 ? 'feed_item_aaf_photo_attachments' : '') ?>'>
              <?php if ($action->attachment_count > 0 && count($action->getAttachments()) > 0): ?>
                <?php
                if (count($action->getAttachments()) == 1 &&
                        null != ( $richContent = $this->getRichContent(current($action->getAttachments())->item))):
                  ?>
                  <?php echo $richContent; ?>
                <?php else: ?>
                  <?php $isIncludeFirstAttachment = false; ?>
                  <?php $isIncludeSecondAttachment = 0; ?>
                <?php $i = 0;?>
                  <?php foreach ($action->getAttachments() as $attachment): ?>
                    <?php $i++;?>
                    <?php if($i > 5) :?>
                    <?php break;?>
                    <?php endif;?>
                    <span class='feed_attachment_<?php echo $attachment->meta->type ?>'>
                      <?php if ($attachment->meta->mode == 0): // Silence ?>
                      <?php elseif ($attachment->meta->mode == 1): // Thumb/text/title type actions ?>
                        <div class="feed_attachment_aaf">
                          <?php if ($attachment->item->getPhotoUrl()): ?>
                            <?php
                            if ($attachment->item->getType() == "core_link") {
                              $attribs = Array('target' => '_blank');
                            } else {
                              $attribs = Array();
                            }
                            ?>       

                            <?php if (SEA_ACTIVITYFEED_LIGHTBOX && strpos($attachment->meta->type, '_photo')): ?>
                              <?php $attribs = @array_merge($attribs, array('onclick' => 'openSeaocoreLightBox("' . $attachment->item->getHref() . '");return false;')); ?>
                            <?php endif; ?>
                            <?php if (strpos($attachment->meta->type, '_photo')): ?>
                              <?php if ($this->onViewPage): ?>
                                <?php $attribs['class'] = 'aaf-feed-photo'; ?>
                                <?php echo $this->htmlLink($attachment->item->getHref(), $this->itemPhoto($attachment->item, 'thumb.main', $attachment->item->getTitle(), array('class' => 'aaf-feed-photo-main')), $attribs) ?>
                              <?php else: ?>
                                <?php $attribs['class'] = 'aaf-feed-photo'; ?>
                                <?php if ($this->showLargePhoto || $attachment->item->getType() == 'album_photo'): ?>
                                
																<?php $count = count($action->getAttachments()); ?>
																<?php
																switch ($count):
																	case 1:
																		$photoContent = $this->itemPhoto($attachment->item, 'thumb.main', $attachment->item->getTitle(), array('class' => "aaf-feed-photo-1"));
																		break;
																	case 2: 
																		$photoContent = '<span style="background-image: url(' . $attachment->item->getPhotoUrl('thumb.profile') . ');" class="aaf-feed-photo-2"></span>';
																		break;
																	case 3:
																		if (!$isIncludeFirstAttachment):
																			$photoContent = '<span style="background-image: url(' . $attachment->item->getPhotoUrl('thumb.medium') . ');" class="aaf-feed-photo-3-big" ></span>';
																		else:
																			if($attachment->item->getType() == 'album_photo'):
    $photoContent = '<span style="background-image: url(' . $attachment->item->getPhotoUrl('thumb.normal') . ');" class="aaf-feed-photo-3-small" ></span>'; 
else :
    $photoContent = '<span style="background-image: url(' . $attachment->item->getPhotoUrl('thumb.medium') . ');" class="aaf-feed-photo-3-small" ></span>';
 endif;
																		endif;
																		break;
																	case 4:
																		if (!$isIncludeFirstAttachment):
																			$photoContent = '<span style="background-image: url(' . $attachment->item->getPhotoUrl('thumb.medium') . ');" class="aaf-feed-photo-4-big" ></span>';
																		else:
																			if($attachment->item->getType() == 'album_photo'):
    $photoContent = '<span style="background-image: url(' . $attachment->item->getPhotoUrl('thumb.normal') . ');" class="aaf-feed-photo-4-small" ></span>'; 
else :
    $photoContent = '<span style="background-image: url(' . $attachment->item->getPhotoUrl('thumb.medium') . ');" class="aaf-feed-photo-4-small" ></span>';
 endif;
																		endif;
																		break;
																	case 5:
																		if (!$isIncludeFirstAttachment || $isIncludeSecondAttachment == 2):
																			$photoContent = '<span style="background-image: url(' . $attachment->item->getPhotoUrl('thumb.medium') . ');" class="aaf-feed-photo-5-big" ></span>';
																		elseif ($isIncludeFirstAttachment):
																			if($attachment->item->getType() == 'album_photo'):
    $photoContent = '<span style="background-image: url(' . $attachment->item->getPhotoUrl('thumb.normal') . ');" class="aaf-feed-photo-5-small" ></span>'; 
else :
    $photoContent = '<span style="background-image: url(' . $attachment->item->getPhotoUrl('thumb.medium') . ');" class="aaf-feed-photo-5-small" ></span>';
 endif;
																		endif;
																		break;
																	case $count > 5:   
                                if (!$isIncludeFirstAttachment || $isIncludeSecondAttachment == 2):
                                  $photoContent = '<span style="background-image: url(' . $attachment->item->getPhotoUrl('thumb.medium') . ');" class="aaf-feed-photo-5-big" ></span>';
                                elseif ($isIncludeFirstAttachment):
                                 if($attachment->item->getType() == 'album_photo'):
    $photoContent = '<span style="background-image: url(' . $attachment->item->getPhotoUrl('thumb.normal') . ');" class="aaf-feed-photo-5-small" ></span>'; 
else :
    $photoContent = '<span style="background-image: url(' . $attachment->item->getPhotoUrl('thumb.medium') . ');" class="aaf-feed-photo-5-small" ></span>';
 endif;
                                endif;
                                $remainingPhotos = ($count - 5) + 1;     
                                if($i == 5) {
                                    $photoContent .= '<div class="aff_remaining_photo_count">+'.$remainingPhotos.'</div>';
                                }
                                break; 
                              default :
																	default :
																		$photoContent = '<span style="background-image: url(' . $attachment->item->getPhotoUrl('thumb.normal') . ');" class="aaf-feed-photo-9"></span>';
																endswitch;
																echo $this->htmlLink($attachment->item->getHref(), $photoContent, $attribs);
																?>

                                  <?php //echo $this->htmlLink($attachment->item->getHref(), $this->itemPhoto($attachment->item, 'thumb.medium', $attachment->item->getTitle(), array('class' => 'aaf-feed-photo-1')), $attribs) ?>
                                <?php else: ?>
                                  <?php echo $this->htmlLink($attachment->item->getHref(), $this->itemPhoto($attachment->item, 'thumb.normal', $attachment->item->getTitle()), $attribs) ?>
                                <?php endif; ?>
                              <?php endif; ?>
                            <?php else: ?>
                            <?php //$photoContent = $this->itemPhoto($attachment->item, 'thumb.main', $attachment->item->getTitle(), array('class' => "aaf-feed-photo-1"));
                           // echo $this->htmlLink($attachment->item->getHref(), $photoContent, $attribs); ?>
                              <?php echo $this->htmlLink($attachment->item->getHref(), $this->itemPhoto($attachment->item, 'thumb.profile', $attachment->item->getTitle()), $attribs) ?>
                            <?php endif; ?>
                          <?php endif; ?>

                          <div>
                            <div class='feed_item_link_title'>
                              <?php
                              if ($attachment->item->getType() == "core_link") {
                                $attribs = Array('target' => '_blank');
                              } else {
                                $attribs = array('class' => 'sea_add_tooltip_link', 'rel' => $attachment->item->getType() . ' ' . $attachment->item->getIdentity());
                              }
                              echo $this->htmlLink($attachment->item->getHref(), $attachment->item->getTitle() ? $attachment->item->getTitle() : '', $attribs);
                              ?>
                            </div>
                            <div class='feed_item_link_desc'>
                              <?php
                              if ($attachment->item->getType() == "activity_action"):
                                echo $this->getContent($attachment->item, true);
                              else: ?>
                                <?php $attachmentDescription = $attachment->item->getDescription()?>
                                <?php if ($action->body != $attachmentDescription): ?>
                                  <?php echo $this->viewMore($attachmentDescription) ?>
                                <?php endif; ?>
                              <?php endif;
                              ?>
                            </div>
                          </div>
                        </div>
                      <?php elseif ($attachment->meta->mode == 2):  // Thumb only type actions ?>
                        <div class="feed_attachment_photo">
                          <?php $attribs = Array('class' => 'feed_item_thumb aaf-feed-photo'); ?>           
                          <?php if (SEA_ACTIVITYFEED_LIGHTBOX && strpos($attachment->meta->type, '_photo')): ?>
                            <?php $attribs = @array_merge($attribs, array('onclick' => 'openSeaocoreLightBox("' . $attachment->item->getHref() . '");return false;')); ?>
                          <?php endif; ?>
                          <?php if ($this->showLargePhoto || $attachment->item->getType() == 'album_photo'): ?>
                            <?php $count = count($action->getAttachments()); ?>
                            <?php
                            switch ($count):
                              case 1:
                                $photoContent = $this->itemPhoto($attachment->item, 'thumb.main', $attachment->item->getTitle(), array('class' => "aaf-feed-photo-1"));
                                break;
                              case 2: 
                                $photoContent = '<span style="background-image: url(' . $attachment->item->getPhotoUrl('thumb.profile') . ');" class="aaf-feed-photo-2"></span>';
                                break;
                              case 3:
                                if (!$isIncludeFirstAttachment):
                                  $photoContent = '<span style="background-image: url(' . $attachment->item->getPhotoUrl('thumb.medium') . ');" class="aaf-feed-photo-3-big" ></span>';
                                else:
                                if($attachment->item->getType() == 'album_photo'):
    $photoContent = '<span style="background-image: url(' . $attachment->item->getPhotoUrl('thumb.normal') . ');" class="aaf-feed-photo-3-small" ></span>'; 
else :
    $photoContent = '<span style="background-image: url(' . $attachment->item->getPhotoUrl('thumb.medium') . ');" class="aaf-feed-photo-3-small" ></span>';
 endif;
                                endif;
                                break;
                              case 4:
                                if (!$isIncludeFirstAttachment):
                                  $photoContent = '<span style="background-image: url(' . $attachment->item->getPhotoUrl('thumb.medium') . ');" class="aaf-feed-photo-4-big" ></span>';
                                else:
                                    if($attachment->item->getType() == 'album_photo'):
    $photoContent = '<span style="background-image: url(' . $attachment->item->getPhotoUrl('thumb.normal') . ');" class="aaf-feed-photo-4-small" ></span>'; 
else :
    $photoContent = '<span style="background-image: url(' . $attachment->item->getPhotoUrl('thumb.medium') . ');" class="aaf-feed-photo-4-small" ></span>';
 endif;
                                endif;
                                break;
                              case 5:
                                if (!$isIncludeFirstAttachment || $isIncludeSecondAttachment == 2):
                                  $photoContent = '<span style="background-image: url(' . $attachment->item->getPhotoUrl('thumb.medium') . ');" class="aaf-feed-photo-5-big" ></span>';
                                elseif ($isIncludeFirstAttachment):
                                  if($attachment->item->getType() == 'album_photo'):
    $photoContent = '<span style="background-image: url(' . $attachment->item->getPhotoUrl('thumb.normal') . ');" class="aaf-feed-photo-5-small" ></span>'; 
else :
    $photoContent = '<span style="background-image: url(' . $attachment->item->getPhotoUrl('thumb.medium') . ');" class="aaf-feed-photo-5-small" ></span>';
 endif;
                                endif;
                                break;
                              case $count > 5:   
                                if (!$isIncludeFirstAttachment || $isIncludeSecondAttachment == 2):
                                  $photoContent = '<span style="background-image: url(' . $attachment->item->getPhotoUrl('thumb.medium') . ');" class="aaf-feed-photo-5-big" ></span>';
                                elseif ($isIncludeFirstAttachment):
                                  if($attachment->item->getType() == 'album_photo'):
    $photoContent = '<span style="background-image: url(' . $attachment->item->getPhotoUrl('thumb.normal') . ');" class="aaf-feed-photo-5-small" ></span>'; 
else :
    $photoContent = '<span style="background-image: url(' . $attachment->item->getPhotoUrl('thumb.medium') . ');" class="aaf-feed-photo-5-small" ></span>';
 endif;
                                endif;
                                $remainingPhotos = ($count - 5) + 1;     
                                if($i == 5) {
                                    $photoContent .= '<div class="aff_remaining_photo_count">+'.$remainingPhotos.'</div>';
                                }
                                break; 
                              default :
                                $photoContent = '<span style="background-image: url(' . $attachment->item->getPhotoUrl('thumb.normal') . ');" class="aaf-feed-photo-9"></span>';
                            endswitch;
                            echo $this->htmlLink($attachment->item->getHref(), $photoContent, $attribs);
                            ?>
                          <?php else: ?>
                          <?php //$photoContent = $this->itemPhoto($attachment->item, 'thumb.main', $attachment->item->getTitle(), array('class' => "aaf-feed-photo-1"));
                            //echo $this->htmlLink($attachment->item->getHref(), $photoContent, $attribs); ?>
                            <?php echo $this->htmlLink($attachment->item->getHref(), $this->itemPhoto($attachment->item, 'thumb.normal', $attachment->item->getTitle()), $attribs) ?>
                          <?php endif; ?>
                        </div>
                      <?php elseif ($attachment->meta->mode == 3): // Description only type actions  ?>
                        <?php echo $this->viewMore($attachment->item->getDescription()); ?>
                      <?php elseif ($attachment->meta->mode == 4): // Multi collectible thingy (@todo) ?>
                      <?php endif; ?>
                    </span>
                    <?php
                    $isIncludeFirstAttachment = true;
                    $isIncludeSecondAttachment = $isIncludeSecondAttachment + 2;
                    ?>
                  <?php endforeach; ?>
                <?php endif; ?>
              <?php endif; ?>
            </div>
          <?php endif; ?>
          <?php if(!empty($this->hashtag[$action->action_id]) && !empty($this->showHashtags)){?>
            <div class="hashtag_activity_item">
                <ul>
                  <?php $url = $this->url(array('controller' => 'index', 'action' => 'index'),"sitehashtag_general")."?search=";
                        for ($i = 0; $i < count($this->hashtag[$action->action_id]); $i++) { ?>
                            <li> 
                                <a href="<?php echo $url.urlencode($this->hashtag[$action->action_id][$i]);?>"><?php  echo $this->hashtag[$action->action_id][$i]; ?></a>
                            </li>
                        <?php } ?>
                </ul>
            </div>
          <?php }?>
          <div id='comment-likes-activity-item-<?php echo $actionBaseId ?>' class='comment-likes-activity-item'>
            <?php // Icon, time since, action links ?>
            <?php
            $icon_type = 'activity_icon_' . $action->type;
            list($attachment) = $action->getAttachments();
            if (is_object($attachment) && $action->attachment_count > 0 && $attachment->item):
              $icon_type .= ' item_icon_' . $attachment->item->getType() . ' ';
            endif;
            $canComment = ( isset($action) && $action->getTypeInfo()->commentable && $action->commentable &&
                    $this->viewer()->getIdentity() &&
                    Engine_Api::_()->authorization()->isAllowed($action->getCommentObject(), null, 'comment') &&
                    !empty($this->commentForm) );
            ?>

            <?php if (is_array($action->params) && isset($action->params['checkin']) && !empty($action->params['checkin'])): ?>
              <?php if (isset($action->params['checkin']['type']) && $action->params['checkin']['type'] == 'Page'): ?>
                <?php $icon_type = "item_icon_sitepage"; ?>
              <?php elseif (isset($action->params['checkin']['type']) && $action->params['checkin']['type'] == 'Business'): ?>
                <?php $icon_type = "item_icon_sitebusiness"; ?>
              <?php elseif (isset($action->params['checkin']['type']) && $action->params['checkin']['type'] == 'Group'): ?>
                <?php $icon_type = "item_icon_sitegroup"; ?>
              <?php elseif (isset($action->params['checkin']['type']) && $action->params['checkin']['type'] == 'Store'): ?>
                <?php $icon_type = "item_icon_sitestore"; ?>
              <?php else: ?>
                <?php $icon_type = "item_icon_sitetagcheckin"; ?>
              <?php endif; ?>
            <?php endif; ?>

            <div class='feed_item_date feed_item_icon <?php echo $icon_type ?>'>
              <ul>         
                  
                <?php if ($canComment): ?>
                  <?php if($showAsLike):?>
                    <?php if ($action->likes()->isLike($this->viewer())): ?>
                      <li class="feed_item_option_unlike">              
                        <?php echo $this->htmlLink('javascript:void(0);', $this->translate('Unlike'), array('onclick' => 'javascript:en4.advancedactivity.unlike(this,' . $action->action_id . ');', 'action-title' => $this->translate('Like'))) ?>
                        <span>&#183;</span>
                      </li>
                    <?php else: ?>
                      <li class="feed_item_option_like">              	
                        <?php
                        echo $this->htmlLink('javascript:void(0);', $this->translate('Like'), array('onclick' => 'javascript:en4.advancedactivity.like(this,' . $action->action_id . ');', 'action-title' => $this->translate('Unlike')))
                        ?>
                        <span>&#183;</span>
                      </li>
                    <?php endif; ?>
                  
                  <?php else :?>
                      <?php if (!$action->likes()->isLike($this->viewer())): ?>
                        <li class="feed_item_option_like nstcomment_wrap"> 

                            <?php if(!$showLikeWithoutIcon):?>     
                                <?php
                                echo $this->htmlLink('javascript:void(0);', $this->translate('Like'), array('onclick' => 'javascript:en4.advancedactivity.like(this,' . $action->action_id . ');', 'action-title' => '<img src="application/modules/Core/externals/images/loading.gif" />', 'class' => 'nstcomment_like'))
                                ?>
                            <span>&#183;</span>
                            <?php else:?>
                            
                                <?php if($showLikeWithoutIcon == 3):?>
                                <?php
                                //echo $this->htmlLink('javascript:void(0);', $this->translate('Vote up'), array('onclick' => 'javascript:en4.advancedactivity.like(this,' . $action->action_id . ');', 'action-title' => '<img src="application/modules/Core/externals/images/loading.gif" />'))
                                ?> 
                             
                                
                                <?php if ($action->likes()->getLikeCount() > 0): ?>
                                           <?php $url = $this->url(array('module' => 'nestedcomment', 'controller' => 'like', 'action' => 'activity-like', 'action_id' => $action->action_id, 'call_status' => 'public', 'showLikeWithoutIcon' => 3), 'default', true);?>
                                             <a href="javascript:void(0);" onclick="Smoothbox.open('<?php echo $url;?>')"><?php echo $action->likes()->getLikeCount();?></a>
                                       <?php endif ?>
                                       
                                <a href="javascript:void(0)" onclick="en4.advancedactivity.like(this, '<?php echo $action->action_id ?>');" action-title='<img src="application/modules/Core/externals/images/loading.gif" />'>
                                           <img title="<?php echo $this->translate('Vote up');?>" src="application/modules/Nestedcomment/externals/images/arrow-up.png" />
                                         </a>
                                <span>|</span>
                                <?php else:?>
                                 <?php
                                echo $this->htmlLink('javascript:void(0);', $this->translate('Like'), array('onclick' => 'javascript:en4.advancedactivity.like(this,' . $action->action_id . ');', 'action-title' => '<img src="application/modules/Core/externals/images/loading.gif" />'))
                                ?>
                                <span>&#183;</span>
                                <?php endif;?>
                            <?php endif;?>
                            
                        </li>
                      <?php else :?>
                         <li class="nstcomment_wrap feed_item_option_like"> 
                             
                             
                            <?php if($showLikeWithoutIcon != 3):?>     
                                <?php //SHOW ICON WITH LIKE?>
                                    <?php if(!$showLikeWithoutIcon):?>
                                        <img  src="application/modules/Nestedcomment/externals/images/like_light.png" />
                                    <?php endif;?>
                                <?php
                                //DISABLE LINK
                                echo $this->translate('Like');
                                ?>
                                <span>&#183;</span>
                            <?php else:?>
                              <?php if ($action->likes()->getLikeCount() > 0): ?>
                                            <?php $url = $this->url(array('module' => 'nestedcomment', 'controller' => 'like', 'action' => 'activity-like', 'action_id' => $action->action_id, 'call_status' => 'public', 'showLikeWithoutIcon' => 3), 'default', true);?>
                                             <a href="javascript:void(0);" onclick="Smoothbox.open('<?php echo $url;?>')"><?php echo $action->likes()->getLikeCount();?></a>
                                       <?php endif ?>
                              <img  src="application/modules/Nestedcomment/externals/images/arrow-up_light.png" />
                              <span>|</span>
                            <?php endif;?>
                            
                        </li>
                      <?php endif;?>
                      
                       <?php if (!$action->dislikes()->isDislike($this->viewer())):?>
                        <li class="nstcomment_wrap feed_item_option_unlike">  
                            
                         <?php if(!$showLikeWithoutIcon):?>       
                         <?php echo $this->htmlLink('javascript:void(0);', $this->translate('Dislike'), array('onclick' => 'javascript:en4.advancedactivity.unlike(this,' . $action->action_id . ');', 'action-title' => '<img src="application/modules/Core/externals/images/loading.gif" />', 'class' => 'nstcomment_unlike')); ?>
                         
                         <?php else:?>
                         
                          <?php if($showLikeWithoutIcon != 3):?>
                          <?php echo $this->htmlLink('javascript:void(0);', $this->translate('Dislike'), array('onclick' => 'javascript:en4.advancedactivity.unlike(this,' . $action->action_id . ');', 'action-title' => '<img src="application/modules/Core/externals/images/loading.gif" />')); ?>
                          <?php else:?>
                          <?php //echo $this->htmlLink('javascript:void(0);', $this->translate('Dislike'), array('onclick' => 'javascript:en4.advancedactivity.unlike(this,' . $action->action_id . ');', 'action-title' => '<img src="application/modules/Core/externals/images/loading.gif" />')); ?>
                          <?php if ($action->dislikes()->getDisLikeCount() > 0): ?>
                                            <?php $url = $this->url(array('module' => 'nestedcomment', 'controller' => 'like', 'action' => 'activity-dislike',  'action_id' => $action->action_id, 'call_status' => 'public', 'showLikeWithoutIcon' => 3), 'default', true);?>
                                             <a href="javascript:void(0);" onclick="Smoothbox.open('<?php echo $url;?>')"><?php echo $action->dislikes()->getDisLikeCount();?></a>
                                       <?php endif ?>
                           <a href="javascript:void(0)" onclick="en4.advancedactivity.unlike(this, '<?php echo $action->action_id ?>');" action-title='<img src="application/modules/Core/externals/images/loading.gif" />'>
                                           <img title="<?php echo $this->translate('Vote down');?>" src="application/modules/Nestedcomment/externals/images/arrow-down.png" />
                                         </a>
                          
                          <?php endif;?>
                          
                         <?php endif;?>
                         <span>&#183;</span>
                       </li>
                      <?php else:?>
                        <li class="feed_item_option_unlike nstcomment_wrap"> 
                         
                            <?php if($showLikeWithoutIcon != 3):?>     
                                <?php //SHOW ICON WITH LIKE?>
                                    <?php if(!$showLikeWithoutIcon):?>
                                        <img  src="application/modules/Nestedcomment/externals/images/dislike_light.png" />
                                    <?php endif;?>
                                <?php
                                //DISABLE LINK
                                echo $this->translate('Dislike');
                                ?>
                            <?php else:?>
                              <?php if ($action->dislikes()->getDisLikeCount() > 0): ?>
                                            <?php $url = $this->url(array('module' => 'nestedcomment', 'controller' => 'like', 'action' => 'activity-dislike', 'action_id' => $action->action_id, 'call_status' => 'public', 'showLikeWithoutIcon' => 3), 'default', true);?>
                                             <a href="javascript:void(0);" onclick="Smoothbox.open('<?php echo $url;?>')"><?php echo $action->dislikes()->getDisLikeCount();?></a>
                                       <?php endif ?>
                              <img  src="application/modules/Nestedcomment/externals/images/arrow-down_light.png" title="<?php echo $this->translate('Vote down');?>"/>
                            <?php endif;?>
                          <span>&#183;</span>
                        </li>
                      <?php endif;?>
                      
                  <?php endif;?>
                  
                  <?php if (Engine_Api::_()->getApi('settings', 'core')->core_spam_comment): // Comments - likes  ?>
                    <li class="feed_item_option_comment">               
                      <?php
                      echo $this->htmlLink(array('route' => 'default', 'module' => 'activity', 'controller' => 'index', 'action' => 'viewcomment', 'action_id' => $action->getIdentity(), 'format' => 'smoothbox'), $this->translate('Comment'), array(
                          'class' => 'smoothbox', 'title' => $this->translate('Leave a comment')
                      ))
                      ?>
                      <span>&#183;</span>
                    </li>
                  <?php else: ?>
                    <li class="feed_item_option_comment">
                        
                      <?php
                      echo $this->htmlLink('javascript:void(0);', $this->translate('Comment'), array('onclick' =>'showCommentBox("' . $this->commentForm->getAttrib('id') . '", "' . $this->commentForm->body->getAttrib('id') . '"); 
document.getElementById("' . $this->commentForm->submit->getAttrib('id') . '").style.display = "' . (($this->isMobile || !$this->commentShowBottomPost || Engine_Api::_()->getApi('settings', 'core')->core_spam_comment) ? "block" : "none") . '";
 if(document.getElementById("feed-comment-form-open-li_' . $actionBaseId . '")){
document.getElementById("feed-comment-form-open-li_' . $actionBaseId . '").style.display = "none";}  
document.getElementById("' . $this->commentForm->body->getAttrib('id') . '").focus();document.getElementById("' . "comment-likes-activityboox-item-$actionBaseId" . '").style.display = "block";', 'title' => $this->translate('Leave a comment'))) ?>
                      <span>&#183;</span>
                    </li>              
                  <?php endif; ?>
                <?php endif; ?>
                <?php if (in_array($action->getTypeInfo()->type, array('signup', 'friends', 'friends_follow'))): ?>    
                  <?php $userFriendLINK = $this->aafUserFriendshipAjax($action); ?>
                  <?php if ($userFriendLINK): ?>
                    <li class="feed_item_option_add_tag"><?php echo $userFriendLINK; ?>
                      <span>&#183;</span></li>  
                  <?php endif; ?>
                <?php endif; ?>    
                <?php
                if ($this->viewer()->getIdentity() && (
                        'user' == $action->subject_type && $this->viewer()->getIdentity() == $action->subject_id) && $advancedactivityCoreApi->hasFeedTag($action)
                ):
                  ?>
                  <li class="feed_item_option_add_tag">             
                    <?php
                    echo $this->htmlLink(array(
                        'route' => 'default',
                        'module' => 'advancedactivity',
                        'controller' => 'feed',
                        'action' => 'tag-friend',
                        'id' => $action->action_id
                            ), $this->translate('Tag Friends'), array('class' => 'smoothbox', 'title' =>
                        $this->translate('Tag more friends')))
                    ?>
                    <span>&#183;</span>
                  </li>
                <?php elseif ($this->viewer()->getIdentity() && $advancedactivityCoreApi->hasMemberTagged($action, $this->viewer())): ?>  
                  <li class="feed_item_option_remove_tag">             
                    <?php
                    echo $this->htmlLink(array(
                        'route' => 'default',
                        'module' => 'advancedactivity',
                        'controller' => 'feed',
                        'action' => 'remove-tag',
                        'id' => $action->action_id
                            ), $this->translate('Remove Tag'), array('class' => 'smoothbox'))
                    ?>
                    <span>&#183;</span>
                  </li>
                <?php endif; ?>


                <?php // Share ?>
                <?php if ($action->getTypeInfo()->shareable && $action->shareable && $this->viewer()->getIdentity()): ?>
                  <?php if ($action->getTypeInfo()->shareable == 1 && $action->attachment_count == 1 && ($attachment = $action->getFirstAttachment())): ?>
                    <li class="feed_item_option_share">               
                      <?php
                      echo $this->htmlLink(array('route' => 'default', 'module' => 'seaocore',
                          'controller' => 'activity', 'action' => 'share', 'type' => $attachment->item->getType(), 'id' =>
                          $attachment->item->getIdentity(), 'action_id' => $action->getIdentity(), 'format' => 'smoothbox', "not_parent_refresh" => 1), $this->translate('ADVACADV_SHARE'), array('class' => 'smoothbox', 'title' => $this->translate('Share this by re-posting it with your own message.')))
                      ?>
                      <span>&#183;</span>
                    </li>
                  <?php elseif ($action->getTypeInfo()->shareable == 2): ?>
                    <li class="feed_item_option_share">               
                      <?php
                      echo $this->htmlLink(array('route' => 'default', 'module' => 'seaocore',
                          'controller' => 'activity', 'action' => 'share', 'type' => $subject->getType(), 'id' =>
                          $subject->getIdentity(), 'action_id' => $action->getIdentity(), 'format' => 'smoothbox', "not_parent_refresh" => 1), $this->translate('ADVACADV_SHARE'), array('class' => 'smoothbox', 'title' => $this->translate('Share this by re-posting it with your own message.')))
                      ?>
                      <span>&#183;</span>
                    </li>
                  <?php elseif ($action->getTypeInfo()->shareable == 3): ?>
                    <li class="feed_item_option_share">                
                      <?php
                      echo $this->htmlLink(array('route' => 'default', 'module' => 'seaocore',
                          'controller' => 'activity', 'action' => 'share', 'type' => $object->getType(), 'id' =>
                          $object->getIdentity(), 'action_id' => $action->getIdentity(), 'format' => 'smoothbox', 'not_parent_refresh' => 1), $this->translate('ADVACADV_SHARE'), array('class' => 'smoothbox', 'title' => $this->translate('Share this by re-posting it with your own message.')))
                      ?>
                      <span>&#183;</span>
                    </li>
                  <?php elseif ($action->getTypeInfo()->shareable == 4): ?>
                    <li class="feed_item_option_share">                
                      <?php
                      echo $this->htmlLink(array('route' => 'default', 'module' => 'seaocore',
                          'controller' => 'activity', 'action' => 'share', 'type' => $action->getType(), 'id' =>
                          $action->getIdentity(), 'action_id' => $action->getIdentity(), 'format' => 'smoothbox', 'not_parent_refresh' => 1), $this->translate('ADVACADV_SHARE'), array('class' => 'smoothbox', 'title' => $this->translate('Share this by re-posting it with your own message.')))
                      ?>
                      <span>&#183;</span>
                    </li>
                  <?php endif; ?>
                <?php endif; ?>              
                <?php if ($canComment && $this->aaf_comment_like_box): ?> 
                  <?php $likeCount = $action->likes()->getLikeCount(); ?>
                  <?php $commentCount = $action->comments()->getCommentCount() ?> 
                  <?php $dislikeCount = $action->dislikes()->getDislikePaginator()->getTotalItemCount(); ?>
                  <?php if ($likeCount || $commentCount || $dislikeCount): ?>
                    <li class="like_comment_counts" onclick="$('comment-likes-activityboox-item-<?php echo $actionBaseId ?>').toggle()">
                      <?php if ($likeCount): ?>
                        <span class="nstcomment_like"><?php echo $this->locale()->toNumber($likeCount); ?></span>
                      <?php endif; ?>
                      
                       <?php if ($dislikeCount && !$showAsLike): ?>
                        <span class="nstcomment_unlike"><?php echo $this->locale()->toNumber($dislikeCount); ?></span>
                      <?php endif; ?>
                      
                      <?php if ($commentCount): ?>
                        <span class="comment_icon"><?php echo $this->locale()->toNumber($commentCount); ?></span>
                      <?php endif; ?>
                      <span>&#183;</span>
                    </li>
                  <?php endif; ?>
                <?php endif; ?>
                <li>
                  <?php echo $this->timestamp($action->getTimeValue()) ?>
                  <?php $category = $action->getCategory(); ?>
                  <?php if ($category): ?>
                    <span class = "aaf_feed_category feed_item_option_add_tag">
                      <?php echo $this->translate("in %s", $this->htmlLink($category->getHref(), $this->translate($category->getTitle()), array('class' => ''))) ?>
                    </span>
                  <?php endif; ?>
                </li>
                <?php if (null != ( $postAgent = $action->postAgent())): ?>
                  <span>&#183;</span>
                  <?php echo $this->translate("via $postAgent"); ?>
                <?php endif; ?>
                <?php if (!empty($privacy_icon_class) && !empty($privacy_titile)): ?>
                  <li>
                    <span>&#183;</span>
                    <span class = "<?php echo $privacy_icon_class ?> feed_item_privacy">
                      <p class="adv_item_privacy_tip">
                        <img src="<?php echo $this->layout()->staticBaseUrl ?>application/modules/Advancedactivity/externals/images/tooltip-arrow-down.png" alt="" />
                        <?php echo $this->translate("Shared with %s", $this->translate($privacy_titile)) ?>
                      </p>
                    </span>            
                  </li>
                <?php endif; ?>
              </ul>
            </div>


            <?php if (($action->getTypeInfo()->shareable && $action->shareable && ($share = $sharesTable->countShareOfItem(array('parent_action_id' => $action->getIdentity()))) > 0) || ($action->getTypeInfo()->commentable && $action->commentable)) : // Comments - likes -share  ?>
              <div id='comment-likes-activityboox-item-<?php echo $actionBaseId ?>' class='comments' <?php if (!$this->viewAllLikes && !$this->viewAllComments && $this->aaf_comment_like_box && $this->viewer()->getIdentity()): ?>style="display: none;"  <?php endif; ?>>
                <ul class="seao_advcomment">  
                  <?php // Share Count ?>
                  <?php if ($action->getTypeInfo()->shareable && $action->shareable && $share > 0): ?>       
                    <li class="aaf_share_counts">
                      <div></div>
                      <div class="comments_likes">
                        <?php echo $this->htmlLink(array('route' => 'default', 'module' => 'advancedactivity', 'controller' => 'index', 'action' => 'share-item', 'action_id' => $action->getIdentity(), 'format' => 'smoothbox'), $this->translate(array('%s share', '%s shares', $share), $this->locale()->toNumber($share)), array('class' => 'smoothbox seaocore_icon_share aaf_commentbox_icon')) ?>
                      </div>
                    </li>
                  <?php endif; ?>


                  <?php if ($action->getTypeInfo()->commentable && $action->commentable): // Comments - likes -share?> 
                    <?php if($showLikeWithoutIcon != 3) :?>
                    <?php $this->dislikes = $action->dislikes()->getDislikePaginator(); ?>
                    <?php if (($action->likes()->getLikeCount() > 0 && (count($action->likes()->getAllLikesUsers()) > 0)) || ($this->dislikes->getTotalItemCount() > 0 && !$showAsLike)):?>
                    <li>
                    <?php if ($action->likes()->getLikeCount() > 0 && (count($action->likes()->getAllLikesUsers()) > 0)):?>
                        <span class="comments_likes">
                            <?php if ($action->likes()->getLike($this->viewer()) && $action->likes()->getLikeCount() == 1) :?>
                                <?php echo $this->translate(array('%s like this.', '%s likes this.', $action->likes()->getLikeCount()), $this->aafNCFluentList($action->likes()->getAllLikesUsers(), false, $action)) ?>
                            <?php else:?>
                                <?php echo $this->translate(array('%s likes this.', '%s like this.', $action->likes()->getLikeCount()), $this->aafNCFluentList($action->likes()->getAllLikesUsers(), false, $action)) ?>
                            <?php endif;?>
                        </span>
                    <?php endif; ?> 
                    
                    
                    <?php if ($this->dislikes->getTotalItemCount() > 0 && !$showAsLike):?>
                      <?php if($showDislikeUsers) :?>
                      <?php if ($action->likes()->getLikeCount() > 0 && (count($action->likes()->getAllLikesUsers()) > 0)):?>
                      
                         &nbsp;|&nbsp;
                         <?php endif;?>
                          <span class="comments_likes">
                              <?php if ($action->dislikes()->getDislike($this->viewer()) && $this->dislikes->getTotalItemCount() == 1):?>
                              <?php echo $this->translate(array('%s dislike this.', '%s dislikes this.', $this->dislikes->getTotalItemCount()), $this->aafFluentDisLikeList($action->dislikes()->getAllDislikesUsers(), false, $action)) ?>
                           <?php else:?>
                              <?php echo $this->translate(array('%s dislikes this.', '%s dislike this.', $this->dislikes->getTotalItemCount()), $this->aafFluentDisLikeList($action->dislikes()->getAllDislikesUsers(), false, $action)) ?>
                           <?php endif;?>
                          </span>
                        <?php else:?>
                            <?php echo $this->translate(array('%s person dislikes this.', '%s people dislike this.', $this->dislikes->getTotalItemCount()), $this->locale()->toNumber($this->dislikes->getTotalItemCount()));?>
                        <?php endif;?>
                    <?php endif; ?>
                    </li>
                    <?php endif; ?>
                    <?php endif; ?> 
                    <?php if ($action->comments()->getCommentCount() > 0): ?>
                      <?php if ($action->comments()->getCommentCount() > 5 && !$this->viewAllComments): ?>
                        <li>
                          <div></div>
                          <div class="comments_viewall" id="comments_viewall">
                            <?php if (0): ?>
                              <?php
                              echo $this->htmlLink($item->getHref(array('action_id' => $action->action_id, 'show_comments' => true)), $this->translate(array('View all %s comment', 'View all %s comments', $action->comments()->getCommentCount()), $this->locale()->toNumber($action->comments()->getCommentCount())))
                              ?>
                            <?php else: ?>
                              <?php
                              echo $this->htmlLink('javascript:void(0);', $this->translate(array('View all %s comment', 'View all %s comments', $action->comments()->getCommentCount()), $this->locale()->toNumber($action->comments()->getCommentCount())), array('onclick' => 'en4.advancedactivity.viewComments(' . $action->action_id . ');'))
                              ?>
                            <?php endif; ?>
                          </div>
                          <div style="display:none;" id="show_view_all_loading">
                            <img src="application/modules/Core/externals/images/loading.gif" alt="Loading" />
                          </div>
                        </li>
                      <?php endif; ?>
                      <?php foreach ($action->getComments($this->viewAllComments) as $comment): ?>
                      <?php
                        $this->replyForm->setActionIdentity($comment->comment_id);
                        $this->replyForm->comment_id->setValue($comment->comment_id);
                        $this->replyForm->action_id->setValue($action->action_id);
                      ?>
      
											<script type="text/javascript">
                          (function() {
                
                            en4.core.runonce.add(function()  { 
                
                    <?php if ($this->onViewPage): ?>
                                (function() {
                    <?php endif; ?>
                                if (!$('<?php echo $this->replyForm->body->getAttrib('id') ?>'))
                                  return;
                                $('<?php echo $this->replyForm->body->getAttrib('id') ?>').autogrow();
                                
                                //en4.nestedcomment.nestedcomments.attachReply($('<?php echo $this->replyForm->getAttrib('id') ?>'), allowQuickReply);
                
                                if (allowQuickReply == '1' && <?php echo $this->submitReply ? '1' : '0' ?>) {
                                  document.getElementById("<?php echo $this->replyForm->getAttrib('id') ?>").style.display = "";
                                  document.getElementById("<?php echo $this->replyForm->submit->getAttrib('id') ?>").style.display = "none";
                                  if (document.getElementById("feed-reply-form-open-li_<?php echo $comment->comment_id ?>")) {
                                    document.getElementById("feed-reply-form-open-li_<?php echo$comment->comment_id ?>").style.display = "none";
                                  }
                                  document.getElementById("<?php echo $this->replyForm->body->getAttrib('id') ?>").focus();
                                }
                    <?php if ($this->onViewPage): ?>
                                }).delay(1000);
                    <?php endif; ?>
                            });
                          })();
                        </script>
                       
                        
                      <li id="comment-<?php echo $comment->comment_id ?>" class="seao_nestcomment">
                         <?php
                                      if ($this->viewer()->getIdentity() &&
                                            (('user' == $action->subject_type && $this->viewer()->getIdentity() == $action->subject_id) ||
                                            ("user" == $comment->poster_type && $this->viewer()->getIdentity() == $comment->poster_id) ||
                                            ("user" !== $comment->poster_type && Engine_Api::_()->getItemByGuid($comment->poster_type . "_" . $comment->poster_id)->isOwner($this->viewer())) ||
                                            $this->activity_moderate )):
                                        ?>
                      	<span class="seaocore_replies_info_op">
                        	
                            <span class="seaocore_replies_pulldown">
                              <div class="seaocore_dropdown_menu_wrapper">
                                <div class="seaocore_dropdown_menu">
                                  <ul>  
                                      <?php
                                      if ($this->viewer()->getIdentity() &&
                                            (('user' == $action->subject_type && $this->viewer()->getIdentity() == $action->subject_id) ||
                                            ("user" == $comment->poster_type && $this->viewer()->getIdentity() == $comment->poster_id) ||
                                            ("user" !== $comment->poster_type && Engine_Api::_()->getItemByGuid($comment->poster_type . "_" . $comment->poster_id)->isOwner($this->viewer())) ||
                                            $this->activity_moderate )):
                                        ?>
                                    <li>
                                      <?php 
                                        $attachMentArray  = array();
                                        if (!empty($comment->attachment_type) && null !== ($attachment = $this->item($comment->attachment_type, $comment->attachment_id))): ?>
                                        <?php if($comment->attachment_type == 'album_photo'):?>
                                        <?php $status = true; ?>
                                        <?php $photo_id = $attachment->photo_id; ?>
                                        <?php $album_id = $attachment->album_id; ?>
                                        <?php $src = $attachment->getPhotoUrl(); ?>
                                        <?php $attachMentArray = array("status" => $status, "photo_id"=> $photo_id , "album_id" => $attachment->album_id, "src" => $src);?>
                                        <?php endif;?>
                                        <?php endif;?>
                                        
                                        
                                        <script type="text/javascript">  
                                        en4.core.runonce.add(function() {
                                        commentAttachment.editComment['<?php echo $comment->comment_id ?>'] = { 'body': '<?php echo $this->string()->escapeJavascript($comment->body);?>', 'attachment_body':<?php echo Zend_Json_Encoder::encode($attachMentArray);?>}
                                        });
                                        </script>
                                        
                                        
                                        <a href='javascript:void(0);' title="<?php echo $this->translate('Edit') ?>" onclick="en4.nestedcomment.nestedcomments.showCommentEditForm('<?php echo $comment->comment_id?>', '<?php echo ($this->isMobile || !$this->commentShowBottomPost || Engine_Api::_()->getApi('settings', 'core')->core_spam_comment) ? 0 : 1; ?>');"><?php echo $this->translate('Edit'); ?>
                                                               
                                                       </a>
                                          </li>    
                                        <?php endif ?>
                                    <?php
                                      if ($this->viewer()->getIdentity() &&
                                            (('user' == $action->subject_type && $this->viewer()->getIdentity() == $action->subject_id) ||
                                            ("user" == $comment->poster_type && $this->viewer()->getIdentity() == $comment->poster_id) ||
                                            ("user" !== $comment->poster_type && Engine_Api::_()->getItemByGuid($comment->poster_type . "_" . $comment->poster_id)->isOwner($this->viewer())) ||
                                            $this->activity_moderate )):
                                        ?>
                        
                                        <li>
                                      <?php /* echo $this->htmlLink(array(
                                        'route'=>'default',
                                        'module'    => 'advancedactivity',
                                        'controller'=> 'index',
                                        'action'    => 'delete',
                                        'action_id' => $action->action_id,
                                        'comment_id'=> $comment->comment_id,
                                        ),'', array('class' => 'smoothbox
                                        aaf_icon_remove','title'=>$this->translate('Delete Comment'))) */ ?>
                                      <a href="javascript:void(0);" title="<?php
                                      echo
                                      $this->translate('Delete Comment')
                                      ?>" onclick="deletefeed('<?php
                                         echo
                                         $action->action_id
                                         ?>', '<?php echo $comment->comment_id ?>', '<?php
                                         echo
                                         $this->escape($this->url(array('route' => 'default',
                                                     'module' => 'advancedactivity', 'controller' => 'index', 'action' => 'delete')))
                                         ?>')"><?php echo $this->translate('Delete') ?></a>
                                        </li>
                                       <?php endif; ?>
                                  </ul>
                                </div>
                              </div>
                              <span class="seaocore_comment_dropbox"></span>
                            </span>
                          </span>
                        <?php endif;?>
                        <div class="comments_author_photo">
                          <?php
                          echo $this->htmlLink($this->item($comment->poster_type, $comment->poster_id)->getHref(), $this->itemPhoto($this->item($comment->poster_type, $comment->poster_id), 'thumb.icon', $action->getSubject()->getTitle()), array('class' => 'sea_add_tooltip_link', 'rel' => $this->item($comment->poster_type, $comment->poster_id)->getType() . ' ' . $this->item($comment->poster_type, $comment->poster_id)->getIdentity())
                          )
                          ?>
                        </div>
                        <div class="comments_info">
                          <span class='comments_author'>
                            <?php
                            echo $this->htmlLink($this->item($comment->poster_type, $comment->poster_id)->getHref(), $this->item($comment->poster_type, $comment->poster_id)->getTitle(), array('class' => 'sea_add_tooltip_link', 'rel' => $this->item($comment->poster_type, $comment->poster_id)->getType() . ' ' . $this->item($comment->poster_type, $comment->poster_id)->getIdentity())
                            );
                            ?>
                          </span>
                          <span class="comments_body" id="comments_body_<?php echo $comment->comment_id ?>">
                                <?php 
                                    include APPLICATION_PATH . '/application/modules/Seaocore/views/scripts/_commentBody.tpl';
                                ?>
                          </span>
                            
                            <div id="comment_edit_<?php echo $comment->comment_id ?>" class="mtop5 comment_edit" style="display: none;"><?php include APPLICATION_PATH . '/application/modules/Nestedcomment/views/scripts/_editComment.tpl' ?>
                            </div>
                            
                            
                            <?php if (!empty($comment->attachment_type) && null !== ($attachment = $this->item($comment->attachment_type, $comment->attachment_id))): ?>
                          <div class="seaocore_comments_attachment" id="seaocore_comments_attachment_<?php echo $comment->comment_id ?>">
                            <div class="seaocore_comments_attachment_photo">
                              <?php if (null !== $attachment->getPhotoUrl()): ?>
                               <?php if (SEA_ACTIVITYFEED_LIGHTBOX && strpos($comment->attachment_type, '_photo')): ?>
                                    <?php echo $this->htmlLink($attachment->getHref(), $this->itemPhoto($attachment, 'thumb.normal', $attachment->getTitle(), array('class' => 'thumbs_photo')), array('onclick' => 'openSeaocoreLightBox("' . $attachment->getHref() . '");return false;')) ?>
                                     <?php else:?>
                                     <?php echo $this->htmlLink($attachment->getHref(), $this->itemPhoto($attachment, 'thumb.normal', $attachment->getTitle(), array('class' => 'thumbs_photo'))) ?>
                                     <?php endif;?>
                <?php endif; ?>
                            </div>
                            <div class="seaocore_comments_attachment_info">
                              <div class="seaocore_comments_attachment_title">
                <?php echo $this->htmlLink($attachment->getHref(array('message' => $comment->comment_id)), $attachment->getTitle()) ?>
                              </div>
                              <div class="seaocore_comments_attachment_des">
                <?php echo $attachment->getDescription() ?>
                              </div>
                            </div>
                          </div>
                      <?php endif; ?>	
                          <ul class="comments_date">
                            <?php if($canComment) :?>
                            <?php if($showAsNested):?>
                            <li class="feed_item_option_comment"> 
                                     
                              <?php
                              echo $this->htmlLink('javascript:void(0);', $this->translate('Reply'), array('onclick' => ' showReplyBox("' . $this->replyForm->getAttrib('id') . '", "' . $this->replyForm->body->getAttrib('id') . '"); 
                document.getElementById("' . $this->replyForm->submit->getAttrib('id') . '").style.display = "' . (($this->isMobile || !$this->commentShowBottomPost || Engine_Api::_()->getApi('settings', 'core')->core_spam_comment) ? "block" : "none") . '";
                if(document.getElementById("feed-reply-form-open-li_' . $comment->comment_id . '")){
                document.getElementById("feed-reply-form-open-li_' . $comment->comment_id . '").style.display = "none";}  
                document.getElementById("' . $this->replyForm->body->getAttrib('id') . '").focus();document.getElementById("' . "comment-likes-activityboox-item-$actionBaseId" . '").style.display = "block"; ', 'title' =>
                                  $this->translate('Leave a reply')))
                                ?>
                                
                              </li>
                              <?php endif;?>
                        <?php if($showAsLike):?>
                            <?php  $isLiked = $comment->likes()->isLike($this->viewer());?>
                            <li class="comments_like">
                                <?php if($showAsNested):?>
                                   &#183;
                                <?php endif;?>
                              <?php if (!$isLiked): ?>
                                <a href="javascript:void(0)" onclick="en4.advancedactivity.like(this,<?php echo sprintf("'%d', %d", $action->getIdentity(), $comment->getIdentity()) ?>);" action-title="<?php echo $this->translate('unlike') ?>">
                                  <?php echo $this->translate('like') ?>
                                </a>
                              <?php else: ?>
                                <a href="javascript:void(0)" onclick="en4.advancedactivity.unlike(this,<?php echo sprintf("'%d', %d", $action->getIdentity(), $comment->getIdentity()) ?>);" action-title="<?php echo $this->translate('like') ?>">
                                  <?php echo $this->translate('unlike') ?>
                                </a>
                              <?php endif ?>
                            </li>
                        <?php else:?>
                        
                            <?php  $isLiked = $comment->likes()->isLike($this->viewer());?>
                                
                                    <?php if (!$isLiked): ?>
                                        <li class="comments_like"> 
                                        <?php if($showAsNested):?>
                                   &#183;
                                <?php endif;?>
                                        <?php if($showLikeWithoutIconInReplies == 0):?>     
                                        <a class='nstcomment_like' href="javascript:void(0)" onclick="en4.advancedactivity.like(this,<?php echo sprintf("'%d', %d", $action->getIdentity(), $comment->getIdentity()) ?>);" action-title='<img src="application/modules/Core/externals/images/loading.gif" />'>
                                           <?php echo $this->translate('like') ?>
                                         </a>
                                         <?php elseif($showLikeWithoutIconInReplies == 1):?>
                                        <a href="javascript:void(0)" onclick="en4.advancedactivity.like(this,<?php echo sprintf("'%d', %d", $action->getIdentity(), $comment->getIdentity()) ?>);" action-title='<img src="application/modules/Core/externals/images/loading.gif" />'>
                                           <?php echo $this->translate('like') ?>
                                         </a>
                                         <?php elseif($showLikeWithoutIconInReplies == 2):?>
                                         <a class='nstcomment_like' href="javascript:void(0)" onclick="en4.advancedactivity.like(this,<?php echo sprintf("'%d', %d", $action->getIdentity(), $comment->getIdentity()) ?>);" action-title='<img src="application/modules/Core/externals/images/loading.gif" />'>    
                                         </a>
                                         <?php elseif($showLikeWithoutIconInReplies == 3):?>
                                          <?php if ($comment->likes()->getLikeCount() > 0): ?>
                                            <?php $url = $this->url(array('module' => 'nestedcomment', 'controller' => 'like', 'action' => 'likelist', 'resource_type' => $comment->getType(), 'resource_id' => $comment->getIdentity(), 'call_status' => 'public'), 'default', true);?>
                                             <a href="javascript:void(0);" onclick="Smoothbox.open('<?php echo $url;?>')"><?php echo $comment->likes()->getLikeCount();?></a>
                                       <?php endif ?>
                                         <a href="javascript:void(0)" onclick="en4.advancedactivity.like(this,<?php echo sprintf("'%d', %d", $action->getIdentity(), $comment->getIdentity()) ?>);" action-title='<img src="application/modules/Core/externals/images/loading.gif" />'>
                                           <img title="<?php echo $this->translate('Vote up');?>" src="application/modules/Nestedcomment/externals/images/arrow-up.png" />
                                         </a>
                                         <?php endif;?>
                                        </li>
                                    <?php else: ?>
                                        <li class="comments_like nstcomment_wrap"> 
                                   <?php if($showAsNested):?>
                                   &#183;
                                <?php endif;?>
                                    <?php if($showLikeWithoutIconInReplies == 0):?> 
                                      <img src="application/modules/Nestedcomment/externals/images/like_light.png" />
                                      <?php echo $this->translate('like') ?>
                                    <?php elseif($showLikeWithoutIconInReplies == 1):?>
                                       <?php echo $this->translate('like') ?>
                                    <?php elseif($showLikeWithoutIconInReplies == 2):?>
                                      <img src="application/modules/Nestedcomment/externals/images/like_light.png" />
                                    <?php elseif($showLikeWithoutIconInReplies == 3):?>
                                    
                                       <?php if ($comment->likes()->getLikeCount() > 0): ?>
                                            <?php $url = $this->url(array('module' => 'nestedcomment', 'controller' => 'like', 'action' => 'likelist', 'resource_type' => $comment->getType(), 'resource_id' => $comment->getIdentity(), 'call_status' => 'public'), 'default', true);?>
                                             <a href="javascript:void(0);" onclick="Smoothbox.open('<?php echo $url;?>')"><?php echo $comment->likes()->getLikeCount();?></a>
                                       <?php endif ?>
                                       <img title="<?php echo $this->translate('Vote up');?>" src="application/modules/Nestedcomment/externals/images/arrow-up_light.png" />
                                    <?php endif;?>
                                       </li>
                                    <?php endif;?>
                                    
                                <?php $isDisLiked = Engine_Api::_()->getDbtable('dislikes', 'nestedcomment')->isDislike($comment, $this->viewer())?>
                                 
                                    <?php if (!$isDisLiked): ?>
                                       <li class="comments_unlike"> 
                                        &#183; 
                                         <?php if($showLikeWithoutIconInReplies == 0):?>     
                                        <a class='nstcomment_unlike' href="javascript:void(0)" onclick="en4.advancedactivity.unlike(this,<?php echo sprintf("'%d', %d", $action->getIdentity(), $comment->getIdentity()) ?>);" action-title='<img src="application/modules/Core/externals/images/loading.gif" />'>
                                           <?php echo $this->translate('dislike') ?>
                                         </a>
                                         <?php elseif($showLikeWithoutIconInReplies == 1):?>
                                        <a href="javascript:void(0)" onclick="en4.advancedactivity.unlike(this,<?php echo sprintf("'%d', %d", $action->getIdentity(), $comment->getIdentity()) ?>);" action-title='<img src="application/modules/Core/externals/images/loading.gif" />'>
                                           <?php echo $this->translate('dislike') ?>
                                         </a>
                                         <?php elseif($showLikeWithoutIconInReplies == 2):?>
                                         <a class='nstcomment_unlike' href="javascript:void(0)" onclick="en4.advancedactivity.unlike(this,<?php echo sprintf("'%d', %d", $action->getIdentity(), $comment->getIdentity()) ?>);" action-title='<img src="application/modules/Core/externals/images/loading.gif" />'>    
                                         </a>
                                         <?php elseif($showLikeWithoutIconInReplies == 3):?>
                                         
                                         <?php if(Engine_Api::_()->getDbtable('dislikes', 'nestedcomment')->getDislikeCount( $comment ) && !$showAsLike):?>
                                          <?php if($showDislikeUsers) :?>
                                            <?php $url = $this->url(array('module' => 'nestedcomment', 'controller' => 'like', 'action' => 'dislikelist', 'resource_type' => $comment->getType(), 'resource_id' => $comment->getIdentity(), 'call_status' => 'public'), 'default', true);?>
                                                <a href="javascript:void(0);" onclick="Smoothbox.open('<?php echo $url;?>')"><?php echo Engine_Api::_()->getDbtable('dislikes', 'nestedcomment')->getDislikeCount( $comment )?></a>

                                            <?php else:?>
                                                <?php echo Engine_Api::_()->getDbtable('dislikes', 'nestedcomment')->getDislikeCount( $comment )?>
                                            <?php endif;?>   
                                        <?php endif;?>
                                         <a href="javascript:void(0)" onclick="en4.advancedactivity.unlike(this,<?php echo sprintf("'%d', %d", $action->getIdentity(), $comment->getIdentity()) ?>);" action-title='<img src="application/modules/Core/externals/images/loading.gif" />'>
                                           <img title="<?php echo $this->translate('Vote down');?>" src="application/modules/Nestedcomment/externals/images/arrow-down.png" />
                                         </a>
                                         <?php endif;?>
                                       </li>
                                    <?php else: ?>
                                        <li class="comments_unlike nstcomment_wrap"> 
                                    &#183;  
                                    <?php if($showLikeWithoutIconInReplies == 0):?> 
                                      <img src="application/modules/Nestedcomment/externals/images/dislike_light.png" />
                                      <?php echo $this->translate('dislike') ?>
                                    <?php elseif($showLikeWithoutIconInReplies == 1):?>
                                       <?php echo $this->translate('dislike') ?>
                                    <?php elseif($showLikeWithoutIconInReplies == 2):?>
                                      <img src="application/modules/Nestedcomment/externals/images/dislike_light.png" />
                                    <?php elseif($showLikeWithoutIconInReplies == 3):?>
                                    <?php if(Engine_Api::_()->getDbtable('dislikes', 'nestedcomment')->getDislikeCount( $comment ) && !$showAsLike):?>
                                          <?php if($showDislikeUsers) :?>
                                            <?php $url = $this->url(array('module' => 'nestedcomment', 'controller' => 'like', 'action' => 'dislikelist', 'resource_type' => $comment->getType(), 'resource_id' => $comment->getIdentity(), 'call_status' => 'public'), 'default', true);?>
                                               <a href="javascript:void(0);" onclick="Smoothbox.open('<?php echo $url;?>')"><?php echo Engine_Api::_()->getDbtable('dislikes', 'nestedcomment')->getDislikeCount( $comment )?></a>
                                            <?php else:?>
                                                <?php echo Engine_Api::_()->getDbtable('dislikes', 'nestedcomment')->getDislikeCount( $comment )?>
                                            <?php endif;?>
                                        <?php endif;?>
                                       <img title="<?php echo $this->translate('Vote down');?>" src="application/modules/Nestedcomment/externals/images/arrow-down_light.png" />
                                    <?php endif;?>
                                        </li>
                                    <?php endif;?>
                                
                        <?php endif;?>
                        
                      <?php endif ?>
                      <?php if($showLikeWithoutIconInReplies != 3):?>
                            <?php if ($comment->likes()->getLikeCount() > 0): ?>
                              <li class="comments_likes_total"> 
                                  <?php if($canComment || $this->viewer()->getIdentity()) :?>
                                    &#183;
                                   <?php endif;?> 
                                <?php $url = $this->url(array('module' => 'nestedcomment', 'controller' => 'like', 'action' => 'likelist', 'resource_type' => $comment->getType(), 'resource_id' => $comment->getIdentity(), 'call_status' => 'public'), 'default', true);?>
                      <a href="javascript:void(0);" onclick="Smoothbox.open('<?php echo $url;?>')"><?php echo $this->translate(array('%s likes this.', '%s like this.', $comment->likes()->getLikeCount()), $this->locale()->toNumber($comment->likes()->getLikeCount()));?></a>
                      
                              </li>
                            <?php endif ?>
                            
                            <?php if (Engine_Api::_()->getDbtable('dislikes', 'nestedcomment')->getDislikeCount( $comment ) > 0 && !$showAsLike): ?>
                              <li class="comments_likes_total"> 
                                  <?php if($canComment || $this->viewer()->getIdentity()) :?>
                                    &#183;
                                   <?php endif;?> 
                                
                              <?php $url = $this->url(array('module' => 'nestedcomment', 'controller' => 'like', 'action' => 'dislikelist', 'resource_type' => $comment->getType(), 'resource_id' => $comment->getIdentity(), 'call_status' => 'public'), 'default', true);?>
                              <?php if($showDislikeUsers) :?>
                              <a href="javascript:void(0);" onclick="Smoothbox.open('<?php echo $url;?>')"><?php echo $this->translate(array('%s dislikes this.', '%s dislike this.', Engine_Api::_()->getDbtable('dislikes', 'nestedcomment')->getDislikeCount( $comment )), $this->locale()->toNumber(Engine_Api::_()->getDbtable('dislikes', 'nestedcomment')->getDislikeCount( $comment )))?></a>
                              <?php else:?>
                                <?php echo $this->translate(array('%s dislikes this.', '%s dislike this.', Engine_Api::_()->getDbtable('dislikes', 'nestedcomment')->getDislikeCount( $comment )), $this->locale()->toNumber(Engine_Api::_()->getDbtable('dislikes', 'nestedcomment')->getDislikeCount( $comment )))?>
                              <?php endif;?>
                              </li>
                              <?php endif ?>
                            <?php endif ?>
                            <li class="comments_timestamp">
                                <?php if ((Engine_Api::_()->getDbtable('dislikes', 'nestedcomment')->getDislikeCount( $comment ) > 0 && !$showAsLike) || ($comment->likes()->getLikeCount() > 0) || ($this->viewer()->getIdentity() && $canComment)): ?>
                                    &#183;
                                <?php endif ?>
                              <?php echo $this->timestamp($comment->creation_date); ?>
                            </li>
                            
                          </ul>
                          
                          <?php if($showAsNested && count($action->getReplies($comment->comment_id))):?>
                          <a <?php if($defaultViewReplyLink):?>style="display:block;"<?php else:?>style="display:none;"<?php endif;?> id="replies_show_<?php echo $comment->comment_id ?>" class="fleft f_small buttonlink activity_icon_reply_seaocore_reply comments_viewall mtop5" href="javascript:void(0);" onclick="en4.nestedcomment.nestedcomments.loadCommentReplies('<?php echo $comment->comment_id;?>');"><?php echo $this->translate(array("View %s Reply", "View %s Replies", count($action->getReplies($comment->comment_id))), count($action->getReplies($comment->comment_id)));?></a>
                       
                          <a <?php if($defaultViewReplyLink):?>style="display:none;"<?php else:?>style="display:block;"<?php endif;?> id="replies_hide_<?php echo $comment->comment_id ?>" class="fleft f_small buttonlink activity_icon_reply_seaocore_reply comments_viewall mtop5 mbot5" href="javascript:void(0);" onclick="en4.nestedcomment.nestedcomments.hideCommentReplies('<?php echo $comment->comment_id;?>');"><?php echo $this->translate(array("Hide %s Reply", "Hide %s Replies", count($action->getReplies($comment->comment_id))), count($action->getReplies($comment->comment_id)));?></a>
                    		<?php endif;?>
                        </div>

                        <div class="comments">
                        	<ul class="seao_reply">
                            <?php if($showAsNested):?>  
                            <?php foreach ($action->getReplies($comment->comment_id) as $reply): ?>
                              <li id="reply-<?php echo $reply->comment_id ?>" class="reply<?php echo $comment->comment_id;?>" <?php if($defaultViewReplyLink):?>style="display:none;"<?php else:?>style="display:inline-block;"<?php endif;?> >
                                   <?php
                                      if ($this->viewer()->getIdentity() &&
                                            (('user' == $action->subject_type && $this->viewer()->getIdentity() == $action->subject_id) ||
                                            ("user" == $reply->poster_type && $this->viewer()->getIdentity() == $reply->poster_id) ||
                                            ("user" !== $reply->poster_type && Engine_Api::_()->getItemByGuid($reply->poster_type . "_" . $reply->poster_id)->isOwner($this->viewer())) ||
                                            $this->activity_moderate )):
                                        ?>
                              	<span class="seaocore_replies_info_op">
                            <span class="seaocore_replies_pulldown">
                              <div class="seaocore_dropdown_menu_wrapper">
                                <div class="seaocore_dropdown_menu">
                                  <ul>  
                                    <li>
                                    <?php
                                      if ($this->viewer()->getIdentity() &&
                                            (('user' == $action->subject_type && $this->viewer()->getIdentity() == $action->subject_id) ||
                                            ("user" == $reply->poster_type && $this->viewer()->getIdentity() == $reply->poster_id) ||
                                            ("user" !== $reply->poster_type && Engine_Api::_()->getItemByGuid($reply->poster_type . "_" . $reply->poster_id)->isOwner($this->viewer())) ||
                                            $this->activity_moderate )):
                                        ?>

                                       <?php 
                                       $attachMentArray  = array();
                                       if (!empty($reply->attachment_type) && null !== ($attachment = $this->item($reply->attachment_type, $reply->attachment_id))): ?>
                                        <?php if($reply->attachment_type == 'album_photo'):?>
                                          <?php $status = true; ?>
                                          <?php $photo_id = $attachment->photo_id; ?>
                                          <?php $album_id = $attachment->album_id; ?>
                                          <?php $src = $attachment->getPhotoUrl(); ?>
                                          <?php $attachMentArray = array('status' => $status, 'photo_id' => $photo_id , 'album_id' => $attachment->album_id, 'src' => $src);?>
                                          <?php endif;?>
                                        <?php endif;?>
                                        
                                        <script type="text/javascript">  
                                            en4.core.runonce.add(function() {
                                              replyAttachment.editReply['<?php echo $reply->comment_id ?>'] = { 'body': '<?php echo $this->string()->escapeJavascript($reply->body);?>', 'attachment_body':<?php echo Zend_Json_Encoder::encode($attachMentArray);?>}
                                            });
                                        </script>
                                        <a href='javascript:void(0);' title="<?php echo $this->translate('Edit') ?>" onclick="en4.nestedcomment.nestedcomments.showReplyEditForm('<?php echo $reply->comment_id?>', '<?php echo ($this->isMobile || !$this->commentShowBottomPost || Engine_Api::_()->getApi('settings', 'core')->core_spam_comment) ? 0 : 1; ?>');"><?php echo $this->translate('Edit'); ?>  
                                   			</a>
                     								<?php endif ?>
                                    </li>                                            
                                    
                                    <?php
                                      if ($this->viewer()->getIdentity() &&
                                            (('user' == $action->subject_type && $this->viewer()->getIdentity() == $action->subject_id) ||
                                            ("user" == $reply->poster_type && $this->viewer()->getIdentity() == $reply->poster_id) ||
                                            ("user" !== $reply->poster_type && Engine_Api::_()->getItemByGuid($reply->poster_type . "_" . $reply->poster_id)->isOwner($this->viewer())) ||
                                            $this->activity_moderate )):
                                        ?>
      
                                        <li>
                                      <?php /* echo $this->htmlLink(array(
                                        'route'=>'default',
                                        'module'    => 'advancedactivity',
                                        'controller'=> 'index',
                                        'action'    => 'delete',
                                        'action_id' => $action->action_id,
                                        'comment_id'=> $reply->comment_id,
                                        ),'', array('class' => 'smoothbox
                                        aaf_icon_remove','title'=>$this->translate('Delete Reply'))) */ ?>
                                      <a href="javascript:void(0);" title="<?php echo $this->translate('Delete')?>" onclick="deletereply('<?php echo $action->action_id ?>', '<?php echo $reply->comment_id ?>', '<?php echo $this->escape($this->url(array('route' => 'default', 'module' => 'advancedactivity', 'controller' => 'index', 'action' => 'delete'))) ?>')"><?php echo $this->translate('Delete') ?></a>
                                      </li>
                                       <?php endif; ?>
                                  </ul>
                                </div>
                              </div>
                              <span class="seaocore_comment_dropbox"></span>
                            </span>
                          </span>
                          <?php endif;?>
                                <div class="comments_author_photo">
                                  <?php
                                  echo $this->htmlLink($this->item($reply->poster_type, $reply->poster_id)->getHref(), $this->itemPhoto($this->item($reply->poster_type, $reply->poster_id), 'thumb.icon', $action->getSubject()->getTitle()), array('class' => 'sea_add_tooltip_link', 'rel' => $this->item($reply->poster_type, $reply->poster_id)->getType() . ' ' . $this->item($reply->poster_type, $reply->poster_id)->getIdentity())
                                  )
                                  ?>
                                </div>
                                <div class="comments_info">
                                  <span class='comments_author'>
                                    <?php
                                    echo $this->htmlLink($this->item($reply->poster_type, $reply->poster_id)->getHref(), $this->item($reply->poster_type, $reply->poster_id)->getTitle(), array('class' => 'sea_add_tooltip_link', 'rel' => $this->item($reply->poster_type, $reply->poster_id)->getType() . ' ' . $this->item($reply->poster_type, $reply->poster_id)->getIdentity())
                                    );
                                    ?> 
                                  </span>
                                <span class="comments_body" id="reply_body_<?php echo $reply->comment_id ?>">
                                <?php 
                                    include APPLICATION_PATH . '/application/modules/Seaocore/views/scripts/_replyBody.tpl';
                                ?>    
                                </span>
                                    <div id="reply_edit_<?php echo $reply->comment_id ?>" style="display: none;" class="reply_edit"><?php include APPLICATION_PATH . '/application/modules/Nestedcomment/views/scripts/_editReply.tpl' ?>
                                    </div>
                                     
                                    <?php if (!empty($reply->attachment_type) && null !== ($attachment = $this->item($reply->attachment_type, $reply->attachment_id))): ?>
                                  <div class="seaocore_comments_attachment" id="seaocore_comments_attachment_<?php echo $reply->comment_id ?>">
                                    <div class="seaocore_comments_attachment_photo">
                                      <?php if (null !== $attachment->getPhotoUrl()): ?>
                                       <?php if (SEA_ACTIVITYFEED_LIGHTBOX && strpos($reply->attachment_type, '_photo')): ?>
                                            <?php echo $this->htmlLink($attachment->getHref(), $this->itemPhoto($attachment, 'thumb.normal', $attachment->getTitle(), array('class' => 'thumbs_photo')), array('onclick' => 'openSeaocoreLightBox("' . $attachment->getHref() . '");return false;')) ?>
                                             <?php else:?>
                                             <?php echo $this->htmlLink($attachment->getHref(), $this->itemPhoto($attachment, 'thumb.normal', $attachment->getTitle(), array('class' => 'thumbs_photo'))) ?>
                                             <?php endif;?>
                  <?php endif; ?>
                                    </div>
                                    <div class="seaocore_comments_attachment_info">
                                      <div class="seaocore_comments_attachment_title">
                  <?php echo $this->htmlLink($attachment->getHref(array('message' => $reply->comment_id)), $attachment->getTitle()) ?>
                                      </div>
                                      <div class="seaocore_comments_attachment_des">
                  <?php echo $attachment->getDescription() ?>
                                      </div>
                                    </div>
                                  </div>
                              <?php endif; ?>
                                  <ul class="comments_date">
                                    <?php if ($canComment):?>
                                      
                                      <?php if($showAsLike):?>
                                            <?php $isLiked = $reply->likes()->isLike($this->viewer());?>
                                            <li class="comments_like"> 
                                              
                                              <?php if (!$isLiked): ?>
                                                <a href="javascript:void(0)" onclick="en4.advancedactivity.like(this,<?php echo sprintf("'%d', %d", $action->getIdentity(), $reply->getIdentity()) ?>);" action-title="<?php echo $this->translate('unlike') ?>">
                                                  <?php echo $this->translate('like') ?>
                                                </a>
                                              <?php else: ?>
                                                <a href="javascript:void(0)" onclick="en4.advancedactivity.unlike(this,<?php echo sprintf("'%d', %d", $action->getIdentity(), $reply->getIdentity()) ?>);" action-title="<?php echo $this->translate('like') ?>">
                                                  <?php echo $this->translate('unlike') ?>
                                                </a>
                                              <?php endif ?>
                                            </li>
                                      <?php else:?>
                                      
                                      <?php $isLiked = $reply->likes()->isLike($this->viewer());?> 
                                         <?php if(!$isLiked) :?>
                                             <li class="comments_like"> 
                                        
                                        <?php if($showLikeWithoutIconInReplies == 0):?>     
                                        <a class='nstcomment_like' href="javascript:void(0)" onclick="en4.advancedactivity.like(this,<?php echo sprintf("'%d', %d", $action->getIdentity(), $reply->getIdentity()) ?>);" action-title='<img src="application/modules/Core/externals/images/loading.gif" />'>
                                           <?php echo $this->translate('like') ?>
                                         </a>
                                         <?php elseif($showLikeWithoutIconInReplies == 1):?>
                                        <a href="javascript:void(0)" onclick="en4.advancedactivity.like(this,<?php echo sprintf("'%d', %d", $action->getIdentity(), $reply->getIdentity()) ?>);" action-title='<img src="application/modules/Core/externals/images/loading.gif" />'>
                                           <?php echo $this->translate('like') ?>
                                         </a>
                                         <?php elseif($showLikeWithoutIconInReplies == 2):?>
                                         <a class='nstcomment_like' href="javascript:void(0)" onclick="en4.advancedactivity.like(this,<?php echo sprintf("'%d', %d", $action->getIdentity(), $reply->getIdentity()) ?>);" action-title='<img src="application/modules/Core/externals/images/loading.gif" />'>    
                                         </a>
                                         <?php elseif($showLikeWithoutIconInReplies == 3):?>
                                         <?php if ($reply->likes()->getLikeCount() > 0): ?>
                                            <?php $url = $this->url(array('module' => 'nestedcomment', 'controller' => 'like', 'action' => 'likelist', 'resource_type' => $reply->getType(), 'resource_id' => $reply->getIdentity(), 'call_status' => 'public'), 'default', true);?>
                                             <a href="javascript:void(0);" onclick="Smoothbox.open('<?php echo $url;?>')"><?php echo $reply->likes()->getLikeCount();?></a>
                                       <?php endif ?>
                                         <a href="javascript:void(0)" onclick="en4.advancedactivity.like(this,<?php echo sprintf("'%d', %d", $action->getIdentity(), $reply->getIdentity()) ?>);" action-title='<img src="application/modules/Core/externals/images/loading.gif" />'>
                                           <img title="<?php echo $this->translate('Vote up');?>" src="application/modules/Nestedcomment/externals/images/arrow-up.png" />
                                         </a>
                                         <?php endif;?>
                                        </li>
                                       <?php else:?>
                                                <li class="comments_like nstcomment_wrap"> 
                                    
                                    <?php if($showLikeWithoutIconInReplies == 0):?> 
                                      <img src="application/modules/Nestedcomment/externals/images/like_light.png" />
                                      <?php echo $this->translate('like') ?>
                                    <?php elseif($showLikeWithoutIconInReplies == 1):?>
                                       <?php echo $this->translate('like') ?>
                                    <?php elseif($showLikeWithoutIconInReplies == 2):?>
                                      <img src="application/modules/Nestedcomment/externals/images/like_light.png" />
                                    <?php elseif($showLikeWithoutIconInReplies == 3):?>
                                    <?php if ($reply->likes()->getLikeCount() > 0): ?>
                                            <?php $url = $this->url(array('module' => 'nestedcomment', 'controller' => 'like', 'action' => 'likelist', 'resource_type' => $reply->getType(), 'resource_id' => $reply->getIdentity(), 'call_status' => 'public'), 'default', true);?>
                                             <a href="javascript:void(0);" onclick="Smoothbox.open('<?php echo $url;?>')"><?php echo $reply->likes()->getLikeCount();?></a>
                                       <?php endif ?>
                                       <img title="<?php echo $this->translate('Vote up');?>" src="application/modules/Nestedcomment/externals/images/arrow-up_light.png" />
                                    <?php endif;?>
                                        </li>
                                       <?php endif;?>
                                       <?php $isDisLiked = Engine_Api::_()->getDbtable('dislikes', 'nestedcomment')->isDislike($reply, $this->viewer())?>
                                       <?php if(!$isDisLiked) :?>
                                       <li class="comments_unlike"> 
                                        &#183; 
                                        <?php if($showLikeWithoutIconInReplies == 0):?>     
                                        <a class='nstcomment_unlike' href="javascript:void(0)" onclick="en4.advancedactivity.unlike(this,<?php echo sprintf("'%d', %d", $action->getIdentity(), $reply->getIdentity()) ?>);" action-title='<img src="application/modules/Core/externals/images/loading.gif" />'>
                                           <?php echo $this->translate('dislike') ?>
                                         </a>
                                         <?php elseif($showLikeWithoutIconInReplies == 1):?>
                                        <a href="javascript:void(0)" onclick="en4.advancedactivity.unlike(this,<?php echo sprintf("'%d', %d", $action->getIdentity(), $reply->getIdentity()) ?>);" action-title='<img src="application/modules/Core/externals/images/loading.gif" />'>
                                           <?php echo $this->translate('dislike') ?>
                                         </a>
                                         <?php elseif($showLikeWithoutIconInReplies == 2):?>
                                         <a class='nstcomment_unlike' href="javascript:void(0)" onclick="en4.advancedactivity.unlike(this,<?php echo sprintf("'%d', %d", $action->getIdentity(), $reply->getIdentity()) ?>);" action-title='<img src="application/modules/Core/externals/images/loading.gif" />'>    
                                         </a>
                                         <?php elseif($showLikeWithoutIconInReplies == 3):?>
                                         <?php if(Engine_Api::_()->getDbtable('dislikes', 'nestedcomment')->getDislikeCount( $reply ) && !$showAsLike):?>
                                       <?php if($showDislikeUsers) :?>
                                          <?php $url = $this->url(array('module' => 'nestedcomment', 'controller' => 'like', 'action' => 'dislikelist', 'resource_type' => $reply->getType(), 'resource_id' => $reply->getIdentity(), 'call_status' => 'public'), 'default', true);?>
                                                <a href="javascript:void(0);" onclick="Smoothbox.open('<?php echo $url;?>')"><?php echo Engine_Api::_()->getDbtable('dislikes', 'nestedcomment')->getDislikeCount( $reply )?></a>
                                                <?php else:?>
                                                    <?php echo Engine_Api::_()->getDbtable('dislikes', 'nestedcomment')->getDislikeCount( $reply )?>
                                                 <?php endif;?>
                                        <?php endif;?>
                                         <a href="javascript:void(0)" onclick="en4.advancedactivity.unlike(this,<?php echo sprintf("'%d', %d", $action->getIdentity(), $reply->getIdentity()) ?>);" action-title='<img src="application/modules/Core/externals/images/loading.gif" />'>
                                           <img title="<?php echo $this->translate('Vote down');?>" src="application/modules/Nestedcomment/externals/images/arrow-down.png" />
                                         </a>
                                         <?php endif;?>
                                        </li>
                                      <?php else:?>
                                        <li class="comments_unlike nstcomment_wrap">
                                        
                                         &#183;  
                                    <?php if($showLikeWithoutIconInReplies == 0):?> 
                                      <img src="application/modules/Nestedcomment/externals/images/dislike_light.png" />
                                      <?php echo $this->translate('dislike') ?>
                                    <?php elseif($showLikeWithoutIconInReplies == 1):?>
                                       <?php echo $this->translate('dislike') ?>
                                    <?php elseif($showLikeWithoutIconInReplies == 2):?>
                                      <img src="application/modules/Nestedcomment/externals/images/dislike_light.png" />
                                    <?php elseif($showLikeWithoutIconInReplies == 3):?>
                                    <?php if(Engine_Api::_()->getDbtable('dislikes', 'nestedcomment')->getDislikeCount( $reply ) && !$showAsLike):?>
                                       <?php if($showDislikeUsers) :?>
                                          <?php $url = $this->url(array('module' => 'nestedcomment', 'controller' => 'like', 'action' => 'dislikelist', 'resource_type' => $reply->getType(), 'resource_id' => $reply->getIdentity(), 'call_status' => 'public'), 'default', true);?>
                                                <a href="javascript:void(0);" onclick="Smoothbox.open('<?php echo $url;?>')"><?php echo Engine_Api::_()->getDbtable('dislikes', 'nestedcomment')->getDislikeCount( $reply )?></a>
                                                <?php else:?>
                                                <?php echo Engine_Api::_()->getDbtable('dislikes', 'nestedcomment')->getDislikeCount( $reply )?>
                                                <?php endif;?>
                                        <?php endif;?>
                                       <img title="<?php echo $this->translate('Vote down');?>" src="application/modules/Nestedcomment/externals/images/arrow-down_light.png" />
                                    <?php endif;?>
                                        </li>
                                       <?php endif;?>
                                      
                                      <?php endif;?>
                                    <?php endif ?>
                                    
                                    <?php if($showLikeWithoutIconInReplies != 3):?>
                                        <?php if ($reply->likes()->getLikeCount() > 0): ?>
                                          <li class="comments_likes_total">  
                                              <?php if($canComment || $this->viewer()->getIdentity()) :?>
                                    &#183;
                                   <?php endif;?> 
                                            
                                    <?php $url = $this->url(array('module' => 'nestedcomment', 'controller' => 'like', 'action' => 'likelist', 'resource_type' => $reply->getType(), 'resource_id' => $reply->getIdentity(), 'call_status' => 'public'), 'default', true);?>
                      <a href="javascript:void(0);" onclick="Smoothbox.open('<?php echo $url;?>')"><?php echo $this->translate(array('%s likes this.', '%s like this.', $reply->likes()->getLikeCount()), $this->locale()->toNumber($reply->likes()->getLikeCount()));?></a>

                                          </li>
                                        <?php endif ?>

                                        <?php if (Engine_Api::_()->getDbtable('dislikes', 'nestedcomment')->getDislikeCount( $reply ) > 0 && !$showAsLike): ?>
                                            <li class="comments_likes_total"> 
                                                
                                              <?php if($canComment || $this->viewer()->getIdentity()) :?>
                                    &#183;
                                   <?php endif;?>
                                              <?php if($showDislikeUsers) :?>
                                                <?php $url = $this->url(array('module' => 'nestedcomment', 'controller' => 'like', 'action' => 'dislikelist', 'resource_type' => $reply->getType(), 'resource_id' => $reply->getIdentity(), 'call_status' => 'public'), 'default', true);?>
                                                <a href="javascript:void(0);" onclick="Smoothbox.open('<?php echo $url;?>')"><?php echo $this->translate(array('%s dislikes this.', '%s dislike this.', Engine_Api::_()->getDbtable('dislikes', 'nestedcomment')->getDislikeCount( $reply )), $this->locale()->toNumber(Engine_Api::_()->getDbtable('dislikes', 'nestedcomment')->getDislikeCount( $reply )))?></a>
                                                <?php else:?>
                                                    <?php echo $this->translate(array('%s dislikes this.', '%s dislike this.', Engine_Api::_()->getDbtable('dislikes', 'nestedcomment')->getDislikeCount( $reply )), $this->locale()->toNumber(Engine_Api::_()->getDbtable('dislikes', 'nestedcomment')->getDislikeCount( $reply )))?>
                                                <?php endif;?>
                                            </li>
                                        <?php endif ?>
                                    <?php endif ?>
                                    <li class="comments_timestamp"> 
                                         <?php if ((Engine_Api::_()->getDbtable('dislikes', 'nestedcomment')->getDislikeCount( $reply ) > 0 && !$showAsLike) || ($reply->likes()->getLikeCount() > 0) || ($this->viewer()->getIdentity() && $canComment)): ?>
                                    &#183;
                                <?php endif ?>
                                      <?php echo $this->timestamp($reply->creation_date); ?>
                                    </li>
                                  </ul>
                                </div>
                              </li>
                            <?php endforeach;?>
                            <?php endif ?>
                          </ul>
                        </div>
                        
                      </li> 
                        
             					<?php if ($canComment && $showAsNested): ?>      
                        <?php $replyFormId = $this->replyForm->getAttrib('id');?>
                      	<li id='feed-reply-form-open-li_<?php echo $comment->comment_id ?>' onclick='showReplyBox("<?php echo $replyFormId?>");' <?php echo '
document.getElementById("' . $this->replyForm->submit->getAttrib('id') . '").style.display = "' . (($this->isMobile || !$this->commentShowBottomPost || Engine_Api::_()->getApi('settings', 'core')->core_spam_comment) ? "block" : "none") . '";
document.getElementById("feed-reply-form-open-li_' . $comment->comment_id . '").style.display = "none";
  document.getElementById("' . $this->replyForm->body->getAttrib('id') . '").focus();' ?>' <?php if (!$this->commentShowBottomPost || Engine_Api::_()->getApi('settings', 'core')->core_spam_comment): ?> style="display:none;"<?php endif; ?> style="display:none;">                  				<div></div>
                          <div class="seaocore_comment_box seaocore_txt_light"><?php echo $this->translate('Write a reply...') ?></div>
                        </li>
                      <?php endif;?>
                      
                      <?php if ($canComment && $showAsNested) echo $this->replyForm->render();?>  
                      
                      <?php endforeach; ?>
                      	<?php if ($canComment): ?>
                          <?php $commentFormId = $this->commentForm->getAttrib('id');?>
                          <?php $commentFormBodyId = $this->commentForm->body->getAttrib('id');?>
                          <li id='feed-comment-form-open-li_<?php echo $actionBaseId ?>' onclick='<?php echo '
  document.getElementById("' . $this->commentForm->submit->getAttrib('id') . '").style.display = "' . (($this->isMobile || !$this->commentShowBottomPost || Engine_Api::_()->getApi('settings', 'core')->core_spam_comment) ? "block" : "none") . '";
  document.getElementById("feed-comment-form-open-li_' . $actionBaseId . '").style.display = "none";
    document.getElementById("' . $this->commentForm->body->getAttrib('id') . '").focus();' ?> showCommentBox("<?php echo $commentFormId?>", "<?php echo $commentFormId?>");' <?php if (!$this->commentShowBottomPost || Engine_Api::_()->getApi('settings', 'core')->core_spam_comment): ?> style="display:none;"<?php endif; ?> >                  <div></div>
                            <div class="seaocore_comment_box seaocore_txt_light"><?php echo $this->translate('Write a comment...') ?></div></li>
                        <?php endif; ?>
                      <?php endif; ?>
                    <?php endif; ?>  
                </ul>
                <?php if ($canComment) echo $this->commentForm->render(); ?>
                
              </div>
            <?php endif; ?>
          </div>
        </div>
        <?php if (!$this->noList): ?></li><?php endif; ?>

      <?php
      ob_end_flush();
    } catch (Exception $e) {
      ob_end_clean();
      if (APPLICATION_ENV === 'development') {
        echo $e->__toString();
      }
    };
  endforeach;
  ?>
  <?php if (!$this->feedOnly && !$this->onlyactivity): ?>
  </ul>
<?php endif ?>

<script type="text/javascript">

          function deletefeed(action_id, comment_id, action_link) {
            if (comment_id == 0) {

              var msg = "<div class='aaf_show_popup'><h3>" + "<?php echo $this->translate('Delete Activity Item?') ?>" + "</h3><p>" + "<?php echo $this->string()->escapeJavascript($this->translate('Are you sure that you want to delete this activity item? This action cannot be undone.')) ?>" + "</p>" + "<button type='submit' onclick='content_delete_act(" + action_id + ", 0); return false;'>" + "<?php echo $this->string()->escapeJavascript($this->translate('Delete')) ?>" + "</button>" + " <?php echo $this->string()->escapeJavascript($this->translate('or')) ?> " + "<a href='javascript:void(0);'onclick='AAFSmoothboxClose();'>" + "<?php echo $this->string()->escapeJavascript($this->translate('cancel')) ?>" + "</a></div>"

            } else {
              var msg = "<div class='aaf_show_popup'><h3>" + "<?php echo $this->string()->escapeJavascript($this->translate('Delete Comment?')) ?>" + "</h3><p>" + "<?php echo $this->string()->escapeJavascript($this->translate('Are you sure that you want to delete this comment? This action cannot be undone.')) ?>" + "</p>" + "<button type='submit' onclick='content_delete_act(" + action_id + "," + comment_id + "); return false;'>" + "<?php echo $this->string()->escapeJavascript($this->translate('Delete')) ?>" + "</button>" + " <?php echo $this->string()->escapeJavascript($this->translate('or')) ?> " + "<a href='javascript:void(0);'onclick='AAFSmoothboxClose();'>" + "<?php echo $this->string()->escapeJavascript($this->translate('cancel')) ?>" + "</a></div>"
            }
            Smoothbox.open(msg);
          }


function deletereply(action_id, comment_id, action_link) {
            
              var msg = "<div class='aaf_show_popup'><h3>" + "<?php echo $this->string()->escapeJavascript($this->translate('Delete Reply?')) ?>" + "</h3><p>" + "<?php echo $this->string()->escapeJavascript($this->translate('Are you sure that you want to delete this reply? This action cannot be undone.')) ?>" + "</p>" + "<button type='submit' onclick='content_reply_delete_act(" + action_id + "," + comment_id + "); return false;'>" + "<?php echo $this->string()->escapeJavascript($this->translate('Delete')) ?>" + "</button>" + " <?php echo $this->string()->escapeJavascript($this->translate('or')) ?> " + "<a href='javascript:void(0);'onclick='AAFSmoothboxClose();'>" + "<?php echo $this->string()->escapeJavascript($this->translate('cancel')) ?>" + "</a></div>"
               Smoothbox.open(msg);
            }
           

</script>

<script type="text/javascript">
  var content_delete_act = function(action_id, comment_id) {
    if (comment_id == 0) {
      if ($('activity-item-' + action_id))
        $('activity-item-' + action_id).destroy();
    } else {
      if ($('comment-' + comment_id))
        $('comment-' + comment_id).destroy();
     
      if($$('.reply'+comment_id))
          $$('.reply'+comment_id).destroy();
          
      if($('feed-reply-form-open-li_' + comment_id))
         $('feed-reply-form-open-li_' + comment_id).destroy();

      if($('activity-reply-form-' + comment_id))
         $('activity-reply-form-' + comment_id).destroy();
     
    }
    AAFSmoothboxClose();
    url = en4.core.baseUrl + 'advancedactivity/index/delete';
    var request = new Request.JSON({
      'url': url,
      'method': 'post',
      'data': {
        'format': 'json',
        'action_id': action_id,
        'comment_id': comment_id,
        'subject': en4.core.subject.guid
      }
    });
    request.send();
  }
  
  var content_reply_delete_act = function(action_id, comment_id) {
    if (comment_id == 0) {
      if ($('activity-item-' + action_id))
        $('activity-item-' + action_id).destroy();
    } else {
      if ($('reply-' + comment_id))
        $('reply-' + comment_id).destroy();
    }
    AAFSmoothboxClose();
    url = en4.core.baseUrl + 'advancedactivity/index/delete';
    var request = new Request.JSON({
      'url': url,
      'method': 'post',
      'data': {
        'format': 'json',
        'action_id': action_id,
        'comment_id': comment_id,
        'subject': en4.core.subject.guid
      }
    });
    request.send();
  }  

  function showLinkPost(url) {
    url = '<?php echo ((!empty($_ENV["HTTPS"]) && 'on' == strtolower($_ENV["HTTPS"])) ? "https://" : "http://") . $_SERVER['HTTP_HOST'] ?>' + url;
    var content = '<div class="aaf_gtp_pup"><h3><?php echo $this->string()->escapeJavascript($this->translate('Link to this Feed')) ?></h3><div class="aaf_gtp_feed_url">\n\
<p><?php echo $this->string()->escapeJavascript($this->translate('Copy this link to send this feed to others:')) ?></p>\n\
<div>\n\
<input type="text" id="show_link_post_input"  value="' + url + '" readonly="readonly"><span class="bold" style="margin-left:10px;"><a href="' + url + '" target="_blank" noreferrer="true"><?php echo $this->string()->escapeJavascript($this->translate('Go!')) ?> </a></span></div>\n\
</div>\n\
<div>\n\
<p><button name="close" onclick="AAFSmoothboxClose()"><?php echo $this->string()->escapeJavascript($this->translate('Close')) ?></button></p>\n\
</div>\n\
</div>';
    Smoothbox.open(content);
    $('show_link_post_input').select();
  }
  function AAFSmoothboxClose() {
    if (typeof parent.Smoothbox == 'undefined') {
      Smoothbox.close();
    } else {
      parent.Smoothbox.close();
    }
  }
</script>




<?php if($smiliesEnabled):?>
<?php include APPLICATION_PATH . '/application/modules/Nestedcomment/views/scripts/_smilies.tpl' ?>
<style type="text/css">
	.seao_advcomment + form .compose-body #compose-photo-form-fancy-file,
	.seao_advcomment .compose-body #compose-photo-form-fancy-file{
		right: 23px;
	}
</style>
<?php endif;?>