<?php
/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Sitestorevideo
 * @copyright  Copyright 2012-2013 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: view.tpl 2013-09-02 00:00:00Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
?>
<?php 
  include APPLICATION_PATH . '/application/modules/Sitestore/views/scripts/Adintegration.tpl';
?>
<?php 
	$this->headLink()
  ->appendStylesheet($this->layout()->staticBaseUrl . 'application/modules/Sitestorevideo/externals/styles/style_sitestorevideo.css')
?>
<?php if( !$this->video || ($this->video->status!=1)): ?>
	<div class="tip">
		<span>
			<?php echo $this->translate('The video you are looking for does not exist or has not been processed yet.');?>
		</span>
	</div>		
	<?php return; // Do no render the rest of the script in this mode
endif; ?>

<?php if( $this->video->type==3): ?>
	<?php
	  $this->videoPlayerJs();
	?>
<?php
                                                        $coreVersion = Engine_Api::_()->getDbtable('modules', 'core')->getModule('core')->version;

       $flowplayerSwf = $coreVersion < '4.8.10' ? 'flowplayer-3.1.5.swf' : 'flowplayer-3.2.18.swf';?>
  <script type='text/javascript'>
    flashembed("video_embed",
    {
      src: "<?php echo $this->layout()->staticBaseUrl?>externals/flowplayer/<?php echo $flowplayerSwf;?>",
      width: 480,
      height: 386,
      wmode: 'transparent'
    },
    {
      config: {
        clip: {
          url: "<?php echo $this->video_location;?>",
          autoPlay: false,
          duration: "<?php echo $this->video->duration ?>",
          autoBuffering: true
        },
        plugins: {
          controls: {
            background: '#000000',
            bufferColor: '#333333',
            progressColor: '#444444',
            buttonColor: '#444444',
            buttonOverColor: '#666666'
          }
        },
        canvas: {
          backgroundColor:'#000000'
        }
      }
    });
    
  /*var flowplayer = "<?php //echo $this->layout()->staticBaseUrl;?>externals/flowplayer/flowplayer-3.1.5.swf";
  var video_player = new Swiff(flowplayer, {
    width:  320,
    height: 240,
    vars: {
      clip: {
        url: '/engine4/public/video/1000000/1000/68/53.flv',
        autoPlay: false,
        autoBuffering: true
      },
      plugins: {
        controls: {
          background: '#000000',
          bufferColor: '#333333',
          progressColor: '#444444',
          buttonColor: '#444444',
          buttonOverColor: '#666666'
        }
      },
      canvas: {
        backgroundColor:'#000000'
      }
    }
  });
  en4.core.runonce.add(function(){video_player.inject($('video_embed'))});*/

  </script>
<?php endif;?>

<script type="text/javascript">
  var store_id = <?php echo $this->video->store_id;?>;
  var pre_rate = <?php echo $this->video->rating;?>;
  var rated = '<?php echo $this->rated;?>';
  var video_id = <?php echo $this->video->video_id;?>;
  var total_votes = <?php echo $this->rating_count;?>;
  var viewer = <?php echo $this->viewer_id;?>;
  <?php if(empty($this->rating_count)): ?>
  var rating_var =  '<?php echo $this->string()->escapeJavascript($this->translate(" rating")) ?>';
  <?php else: ?>
  var rating_var =  '<?php echo $this->string()->escapeJavascript($this->translate(" ratings")) ?>';
   <?php endif; ?>
   var check_rating = 0;
	var current_total_rate;
  function rating_over(rating) {
    if (rated == 1){
      $('rating_text').innerHTML = "<?php echo $this->translate('you already rated');?>";
      //set_rating();
    }
    else if (viewer == 0){
      $('rating_text').innerHTML = "<?php echo $this->translate('please login to rate');?>";
    }
    else{
      $('rating_text').innerHTML = "<?php echo $this->translate('click to rate');?>";
      for(var x=1; x<=5; x++) {
        if(x <= rating) {
          $('rate_'+x).set('class', 'rating_star_big_generic rating_star_big');
        } else {
          $('rate_'+x).set('class', 'rating_star_big_generic rating_star_big_disabled');
        }
      }
    }
  }
  function rating_out() {
    $('rating_text').innerHTML = " <?php echo $this->translate(array('%s rating', '%s ratings', $this->rating_count),$this->locale()->toNumber($this->rating_count)) ?>";
    if (pre_rate != 0){
      set_rating();
    }
    else {
      for(var x=1; x<=5; x++) {
        $('rate_'+x).set('class', 'rating_star_big_generic rating_star_big_disabled');
      }
    }
  }

  function set_rating() {
    var rating = pre_rate;
     if(check_rating == 1) {
      if(current_total_rate == 1) {
    	  $('rating_text').innerHTML = current_total_rate+rating_var;
      }
      else {
		  	$('rating_text').innerHTML = current_total_rate+rating_var;
    	}
	  }
	  else {
    	$('rating_text').innerHTML = "<?php echo $this->translate(array('%s rating', '%s ratings', $this->rating_count),$this->locale()->toNumber($this->rating_count)) ?>";
	  }
    for(var x=1; x<=parseInt(rating); x++) {
      $('rate_'+x).set('class', 'rating_star_big_generic rating_star_big');
    }
    

    for(var x=parseInt(rating)+1; x<=5; x++) {
      $('rate_'+x).set('class', 'rating_star_big_generic rating_star_big_disabled');
    }

    var remainder = Math.round(rating)-rating;
    if (remainder <= 0.5 && remainder !=0){
      var last = parseInt(rating)+1;
      $('rate_'+last).set('class', 'rating_star_big_generic rating_star_big_half');
    }
  }
  
  function rate(rating) {
    $('rating_text').innerHTML = "<?php echo $this->translate('Thanks for rating!');?>";
    for(var x=1; x<=5; x++) {
      $('rate_'+x).set('onclick', '');
    }
    (new Request.JSON({
      'format': 'json',
      'url' : '<?php echo $this->url(array('module' => 'sitestorevideo', 'controller' => 'index', 'action' => 'rate'), 'default', true) ?>',
      'data' : {
        'format' : 'json',
        'rating' : rating,
        'video_id': video_id,
        'store_id' : store_id
      },
      'onRequest' : function(){
        rated = 1;
        total_votes = total_votes+1;
        pre_rate = (pre_rate+rating)/total_votes;
        set_rating();
      },
      'onSuccess' : function(responseJSON, responseText)
      {
         $('rating_text').innerHTML = responseJSON[0].total+rating_var;
         current_total_rate =  responseJSON[0].total;
         check_rating = 1;
      }
    })).send();
    
  }
  
  var tagAction =function(tag, url){
    $('tag').value = tag;
    window.location.href = url;
  }

  en4.core.runonce.add(set_rating);
  

</script>


<form id='filter_form' class='global_form_box' method='get' style='display:none;'>
  <input type="hidden" id="tag" name="tag" value=""/>
</form>

<div class="sitestore_viewstores_head">
	<?php echo $this->htmlLink(array('route' => 'sitestore_entry_view', 'store_url' => Engine_Api::_()->sitestore()->getStoreUrl($this->sitestore->store_id)), $this->itemPhoto($this->sitestore, 'thumb.icon', '' , array('align'=>'left'))) ?>
	<h2>
	  <?php echo $this->sitestore->__toString() ?>
	  <?php echo $this->translate('&raquo;');?>
	  <?php echo $this->htmlLink(array( 'route' => 'sitestore_entry_view', 'store_url' => Engine_Api::_()->sitestore()->getStoreUrl($this->sitestore->store_id), 'tab' => $this->tab_selected_id), $this->translate('Videos')) ?>
	  <?php echo $this->translate('&raquo;');?>
	  <?php echo $this->video->title ?>
	</h2>
</div>

<div class="layout_right">

	<?php if( count($this->paginator) > 0 ): ?>
 		<div class="generic_layout_container">
	    <?php if(count($this->paginator) > 1):?>
		    <h3> <?php echo $this->translate("Related Videos"); ?> </h3>
	    <?php elseif(count($this->paginator)== 1):?>
		    <h3> <?php echo $this->translate("Related Video"); ?> </h3>
	    <?php endif;?>
		  <ul class="sitestore_sidebar_list">
				<?php foreach ($this->paginator as $sitestorevideo): ?>
					<li> 
						<?php echo $this->htmlLink(
							$sitestorevideo->getHref(),
							$this->itemPhoto($sitestorevideo, 'thumb.icon', $sitestorevideo->getTitle()),
							array('class' => 'list_thumb', 'title' => $sitestorevideo->getTitle())
						) ?>
						<div class='sitestore_sidebar_list_info'>
							<div class='sitestore_sidebar_list_title'>
								<?php echo $this->htmlLink($sitestorevideo->getHref(), Engine_Api::_()->sitestorevideo()->truncation($sitestorevideo->getTitle()), array('title'=> $sitestorevideo->getTitle()));?> 	
							</div>
							<div class='sitestore_sidebar_list_details'>		       
              <?php echo $this->translate(array('%s like', '%s likes', $sitestorevideo->like_count), $this->locale()->toNumber($sitestorevideo->like_count)) ?>
								|
								<?php echo $this->translate(array('%s view', '%s views', $sitestorevideo->view_count ), $this->locale()->toNumber($sitestorevideo->view_count )) ?>
							</div>
						</div>
					</li>
				<?php endforeach; ?>
	      <?php if($this->count_video > $this->limit_sitestorevideo):?>
					<li><a href='<?php echo $this->url(array('tab' => $this->tab_selected_id,'store_id' => $this->sitestore->store_id, 'see_all' => 1), 'sitestorevideo_tagcreate', true) ?>' class="sitestore_seeall_link"><?php echo $this->translate('See All');?> &raquo;</a></li>
				<?php endif;?>
		  </ul>
		 </div>
  <?php endif; ?>
	<!--RIGHT AD START HERE-->
  
  
    <?php if(Engine_Api::_()->getDbtable('modules', 'core')->isModuleEnabled('communityad') && Engine_Api::_()->getApi('settings', 'core')->getSetting('sitestore.communityads', 1) && Engine_Api::_()->getApi('settings', 'core')->getSetting('sitestore.advideoview', 3)  && $store_communityad_integration && Engine_Api::_()->sitestore()->showAdWithPackage($this->sitestore)):?>	
    <div id="communityad_videoview">	
				<?php echo $this->content()->renderWidget("communityad.ads", array( "itemCount"=>Engine_Api::_()->getApi('settings', 'core')->getSetting('sitestore.advideoview', 3),"loaded_by_ajax"=>0,'widgetId'=>"store_videoview"))?>		
			</div>
    <?php endif;?>  
</div>


<!--RIGHT AD END HERE-->
<div class='layout_middle'>
  <div class="sitestorevideo_view">
    <h3>
      <?php echo $this->video->title;?>
    </h3>

    <div class="sitestorevideo_date">
      <?php echo $this->translate('Posted by') ?>
      <?php echo $this->htmlLink($this->video->getParent(), $this->video->getParent()->getTitle()) ?>
    </div>
    <div class="video_desc">
      <?php echo nl2br($this->video->description);?>
    </div>
      <!--FACEBOOK LIKE BUTTON START HERE-->
      
      <?php  $fbmodule = Engine_Api::_()->getDbtable('modules', 'core')->getModule('facebookse');
        if (!empty ($fbmodule)) :
          $enable_facebookse = Engine_Api::_()->getDbtable('modules', 'core')->isModuleEnabled('facebookse'); 
          if (!empty ($enable_facebookse) && !empty($fbmodule->version)) :
            $fbversion = $fbmodule->version; 
            if (!empty($fbversion) && ($fbversion >= '4.1.5')) { ?>
               <div class="sitestorevideo_fb_like">
                <?php echo Engine_Api::_()->facebookse()->isValidFbLike(); ?>
              </div>
            
            <?php } ?>
          <?php endif; ?>
     <?php endif; ?>
  
    <?php if( $this->video->type == 3): ?>
			<div id="video_embed" class="sitestorevideo_embed">
			</div>
    <?php else: ?>
			<div class="sitestorevideo_embed">
				<?php echo $this->videoEmbedded;?>
			</div>
    <?php endif; ?>
    <div class="sitestorevideo_date">
      <?php echo $this->translate('Posted');?> <?php echo $this->timestamp($this->video->creation_date) ?>
       <span class="video_views">- <?php echo $this->translate(array('%s comment', '%s ', $this->video->comments()->getCommentCount()),$this->locale()->toNumber($this->video->comments()->getCommentCount())) ?>	-  
				<?php echo $this->translate(array('%s view', '%s views', $this->video->view_count ), $this->locale()->toNumber($this->video->view_count )) ?>
       - <?php echo $this->translate(array('%s like', '%s likes', $this->video->likes()->getLikeCount()),$this->locale()->toNumber($this->video->likes()->getLikeCount())) ?>
       </span>

      <?php if ($this->category): ?>
        - <?php echo $this->translate('Filed in');?>
        <a href='javascript:void(0);' onclick='javascript:categoryAction(<?php echo $this->category->category_id?>);'>
            <?php echo $this->translate($this->category->category_name) ?>
        </a>
      <?php endif; ?>

      <?php if (count($this->videoTags )):?>
        -
        <?php  foreach ($this->videoTags as $tag): ?>
         <a href='javascript:void(0);' onclick="javascript:tagAction('<?php echo $tag->getTag()->tag_id; ?>', '<?php echo $this->url(array('tag' => $tag->getTag()->tag_id,'store_id' => $this->sitestore->store_id, 'tab' => $this->tab_selected_id), 'sitestorevideo_tagcreate', true); ?>');">
          <?php if(!empty($tag->getTag()->text)):?>#<?php endif;?><?php echo $tag->getTag()->text?></a>&nbsp;
       <?php endforeach; ?>
      <?php  endif; ?>
    </div>
    <div id="video_rating" class="rating" onmouseout="rating_out();">
      <span id="rate_1" class="rating_star_big_generic" <?php if (!$this->rated && $this->viewer_id):?>onclick="rate(1);"<?php endif; ?> onmouseover="rating_over(1);"></span>
      <span id="rate_2" class="rating_star_big_generic" <?php if (!$this->rated && $this->viewer_id):?>onclick="rate(2);"<?php endif; ?> onmouseover="rating_over(2);"></span>
      <span id="rate_3" class="rating_star_big_generic" <?php if (!$this->rated && $this->viewer_id):?>onclick="rate(3);"<?php endif; ?> onmouseover="rating_over(3);"></span>
      <span id="rate_4" class="rating_star_big_generic" <?php if (!$this->rated && $this->viewer_id):?>onclick="rate(4);"<?php endif; ?> onmouseover="rating_over(4);"></span>
      <span id="rate_5" class="rating_star_big_generic" <?php if (!$this->rated && $this->viewer_id):?>onclick="rate(5);"<?php endif; ?> onmouseover="rating_over(5);"></span>
      <span id="rating_text" class="rating_text"><?php echo $this->translate('click to rate');?></span>
    </div>

    <div class='sitestore_video_options'>
				<!--  Start: Suggest to Friend link show work -->
				<?php if( !empty($this->videoSuggLink) && !empty($this->video->search) && !empty($this->video->status) ): ?>				
					<?php echo $this->htmlLink(array('route' => 'default', 'module' => 'suggestion', 'controller' => 'index', 'action' => 'popups', 'sugg_id' => $this->video->video_id, 'sugg_type' => 'store_video'), $this->translate('Suggest to Friends'), array(
						'class'=>'buttonlink  icon_store_friend_suggestion smoothbox')); ?> &nbsp; | &nbsp;			
				<?php endif; ?>					
				<!--  End: Suggest to Friend link show work -->
    	<?php if($this->can_create):?>
					<a href='<?php echo $this->url(array('store_id' => $this->sitestore->store_id,'tab' => $this->tab_selected_id),'sitestorevideo_create', true) ?>' class='buttonlink icon_type_sitestorevideo_new'><?php echo $this->translate('Add Video');?></a>
			<?php endif; ?>   
			<?php if($this->video->owner_id == $this->viewer_id || $this->can_edit == 1): ?>
				&nbsp; | &nbsp;<?php echo $this->htmlLink(array('route' => 'sitestorevideo_edit', 'video_id' => $this->video->video_id,'store_id'=>$this->sitestore->store_id,'tab'=>$this->tab_selected_id), $this->translate('Edit Video'), array(
							'class' => 'buttonlink icon_type_sitestorevideo_edit'
						)) ?>

				&nbsp; | &nbsp;<?php  echo $this->htmlLink(array('route' => 'sitestorevideo_delete', 'video_id' => $this->video->video_id,'store_id'=> $this->sitestore->store_id,'tab'=> $this->tab_selected_id), $this->translate('Delete Video'), array(
								'class' => 'buttonlink icon_type_sitestorevideo_delete'
							));?> &nbsp; | &nbsp;
      <?php elseif($this->can_create):?>
        &nbsp; | &nbsp;
      <?php endif; ?>
      <?php echo $this->htmlLink(Array('module'=> 'activity', 'controller' => 'index', 'action' => 'share', 'route' => 'default', 'type' => 'sitestorevideo_video', 'id' => $this->video->getIdentity(), 'format' => 'smoothbox'), $this->translate("Share"), array('class' => 'smoothbox buttonlink icon_type_sitestorevideo_share')); ?>
  
      <?php if( $this->can_embed ): ?>
			&nbsp; | &nbsp; <?php echo $this->htmlLink(Array('module'=> 'sitestorevideo', 'controller' => 'video', 'action' => 'embed', 'route' => 'default', 'id' => $this->video->getIdentity(), 'format' => 'smoothbox'), $this->translate("Embed"), array('class' => 'smoothbox buttonlink icon_type_sitestorevideo_embed')); ?>
		  <?php endif ?>
   
     &nbsp; | &nbsp; <?php echo $this->htmlLink(Array('module'=> 'core', 'controller' => 'report', 'action' => 'create', 'route' => 'default', 'subject' =>  $this->video->getGuid(), 'format' => 'smoothbox'), $this->translate("Report"), array('class' => 'smoothbox buttonlink icon_type_sitestorevideo_report')); ?>
    </div>

		<?php 
        include_once APPLICATION_PATH . '/application/modules/Seaocore/views/scripts/_listComment.tpl';
    ?>

  </div>
</div>