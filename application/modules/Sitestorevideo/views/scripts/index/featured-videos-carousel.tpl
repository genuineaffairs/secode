<?php

/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Sitestorevideo
 * @copyright  Copyright 2012-2013 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: featured-videos-carousel.tpl 2013-09-02 00:00:00Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
?>

<?php if ($this->direction == 1) { ?>
 <?php  $j=0; $offset=$this->offset; ?>

    <?php foreach ($this->featuredVideos as $video): ?>
      <?php $layout = Engine_Api::_()->getApi('settings', 'core')->getSetting('sitestore.layoutcreate', 0);
			$tab_id = Engine_Api::_()->sitestore()->GetTabIdinfo('sitestorevideo.profile-sitestorevideos', $video->store_id, $layout); ?>
      <?php if($j% $this->itemsVisible ==0):?>
        <div class="Sitestorecontent_SlideItMoo_element Sitestorevideo_SlideItMoo_element" style="width:<?php echo 146 * $this->inOneRow; ?>px;">
        <div class="Sitestorecontent_SlideItMoo_contentList">
      <?php endif;?>
      <div class="featured_thumb_content">
			<a href="<?php echo $this->url(array('user_id' => $video->owner_id, 'video_id' =>  $video->video_id,'tab' => $tab_id,'slug' => $video->getSlug()),'sitestorevideo_view', true)?>" class="thumb_video">
			<div class="sitestore_video_thumb_wrapper">
				<?php if ($video->duration): ?>
					<span class="sitestore_video_length">
						<?php
						if ($video->duration > 360)
						$duration = gmdate("H:i:s", $video->duration); else
						$duration = gmdate("i:s", $video->duration);
						if ($duration[0] == '0')
						$duration = substr($duration, 1); echo $duration;
						?>
					</span>
				<?php endif; ?>
				<?php  if ($video->photo_id): ?>
					<?php echo   $this->itemPhoto($video, 'thumb.normal'); ?>
				<?php else: ?>
					<img src= "<?php echo $this->layout()->staticBaseUrl ?>application/modules/Sitestorevideo/externals/images/video.png" class="thumb_normal item_photo_video  thumb_normal" />
				<?php endif;?>
				</div>
			</a>
			<span class="show_content_des">
				<?php
				$owner = $video->getOwner();
				//$parent = $video->getParent();
				echo 
							$this->htmlLink($video->getHref(), $this->string()->truncate($video->getTitle(),25),array('title' => $video->getTitle(),'class'=>'sitestorevideo_title'));
				?>
        <?php $sitestore_object = Engine_Api::_()->getItem('sitestore_store', $video->store_id);?>
				<?php
				$truncation_limit = Engine_Api::_()->getApi('settings', 'core')->getSetting('sitestore.title.truncation', 18);
				$tmpBody = strip_tags($sitestore_object->title);
				$store_title = ( Engine_String::strlen($tmpBody) > $truncation_limit ? Engine_String::substr($tmpBody, 0, $truncation_limit) . '..' : $tmpBody );
				?>
				<?php echo $this->translate("in ") . $this->htmlLink(Engine_Api::_()->sitestore()->getHref($video->store_id, $video->owner_id, $video->getSlug()),  $store_title,array('title' => $sitestore_object->title)) ?> 
        <?php if(Engine_Api::_()->getApi('settings', 'core')->getSetting('sitestore.postedby', 0)):?>  
					<?php echo $this->translate('by ').
								$this->htmlLink($owner->getHref(), $this->string()->truncate($owner->getTitle(),25),array('title' => $owner->getTitle()));?>
        <?php endif;?>
			</span>
      </div>
        <?php $j++; $offset++;?>
       <?php if(($j% $this->itemsVisible) ==0):?>
           </div>
        </div>    
       <?php endif;?>     
    <?php endforeach; ?>
    <?php if($j <($this->totalItemsInSlide)):?>
       <?php for ($j;$j<($this->totalItemsInSlide); $j++ ): ?>
      <div class="featured_thumb_content">
      </div>
       <?php endfor; ?>
         </div>
      </div>
    <?php endif;?>
     
<?php } else {?>
<?php $count=$this->itemsVisible;
$j=0;  $offset=$this->offset+$count;?>
  <?php for ($i =$count; $i < $this->totalItemsInSlide; $i++):?> 
      <?php if ($j % $this->itemsVisible == 0): ?>
      <div class="Sitestorecontent_SlideItMoo_element Sitestorevideo_SlideItMoo_element" style="width:<?php echo 146 * $this->inOneRow; ?>px;">
        <div class="Sitestorecontent_SlideItMoo_contentList">
      <?php endif; ?>
          <?php if ($i < $this->count): ?>
            <div class="featured_thumb_content">
              <?php $layout = Engine_Api::_()->getApi('settings', 'core')->getSetting('sitestore.layoutcreate', 0);
							$tab_id = Engine_Api::_()->sitestore()->GetTabIdinfo('sitestorevideo.profile-sitestorevideos', $this->featuredVideos[$i]->store_id, $layout); ?>
							<a href="<?php echo $this->url(array('user_id' => $this->featuredVideos[$i]->owner_id, 'video_id' =>  $this->featuredVideos[$i]->video_id,'tab' => $tab_id,'slug' => $this->featuredVideos[$i]->getSlug()),'sitestorevideo_view', true)?>" class="thumb_video">
								<div class="sitestore_video_thumb_wrapper">
									<?php if ($this->featuredVideos[$i]->duration): ?>
										<span class="sitestore_video_length">
											<?php
											if ($this->featuredVideos[$i]->duration > 360)
											$duration = gmdate("H:i:s", $this->featuredVideos[$i]->duration); else
											$duration = gmdate("i:s", $this->featuredVideos[$i]->duration);
											if ($duration[0] == '0')
											$duration = substr($duration, 1); echo $duration;
											?>
										</span>
									<?php endif; ?>
									<?php  if ($this->featuredVideos[$i]->photo_id): ?>
										<?php echo   $this->itemPhoto($this->featuredVideos[$i], 'thumb.normal'); ?>
									<?php else: ?>
										<img src= "<?php echo $this->layout()->staticBaseUrl ?>application/modules/Sitestorevideo/externals/images/video.png" class="thumb_normal item_photo_video  thumb_normal" />
									<?php endif;?>
								</div>
							</a>
							<span class="show_content_des">
            		<?php
                $owner = $this->featuredVideos[$i]->getOwner();
               // $parent = $this->featuredVideos[$i]->getParent();
                echo  $this->htmlLink($this->featuredVideos[$i]->getHref(), $this->string()->truncate($this->featuredVideos[$i]->getTitle(),25),array('title' => $this->featuredVideos[$i]->getTitle(),'class'=>'sitestorevideo_title'));
                ?>
								<?php $sitestore_object = Engine_Api::_()->getItem('sitestore_store', $this->featuredVideos[$i]->store_id);?>
								<?php
								$truncation_limit = Engine_Api::_()->getApi('settings', 'core')->getSetting('sitestore.title.truncation', 18);
								$tmpBody = strip_tags($sitestore_object->title);
								$store_title = ( Engine_String::strlen($tmpBody) > $truncation_limit ? Engine_String::substr($tmpBody, 0, $truncation_limit) . '..' : $tmpBody );
								?>
								<?php echo $this->translate("in ") . $this->htmlLink(Engine_Api::_()->sitestore()->getHref($this->featuredVideos[$i]->store_id, $this->featuredVideos[$i]->owner_id, $this->featuredVideos[$i]->getSlug()),  $store_title,array('title' => $sitestore_object->title)) ?>
                <?php if(Engine_Api::_()->getApi('settings', 'core')->getSetting('sitestore.postedby', 0)):?> 
									<?php echo $this->translate('by ').
											$this->htmlLink($owner->getHref(), $this->string()->truncate($owner->getTitle(),25),array('title' => $owner->getTitle()));?>
                <?php endif;?>
            	</span>
             </div>
          <?php else: ?>
             <div class="featured_thumb_content">
             </div>
          <?php endif; ?>
      <?php $j++; $offset++;?>
      <?php if (($j % $this->itemsVisible) == 0): ?>
          </div>
        </div>
      <?php endif; ?>     
     
  <?php endfor;?>
 <?php $j=0; $offset=$this->offset; ?>
 <?php for ($i = 0; $i < $count; $i++): ?>
   <?php $layout = Engine_Api::_()->getApi('settings', 'core')->getSetting('sitestore.layoutcreate', 0);
			$tab_id = Engine_Api::_()->sitestore()->GetTabIdinfo('sitestorevideo.profile-sitestorevideos', $this->featuredVideos[$i]->store_id, $layout); ?>
   <?php if ($j % $this->itemsVisible == 0): ?>
      <div class="Sitestorecontent_SlideItMoo_element Sitestorevideo_SlideItMoo_element" style="width:<?php echo 146 * $this->inOneRow; ?>px;">
        <div class="Sitestorecontent_SlideItMoo_contentList">
      <?php endif; ?>        
            <div class="featured_thumb_content">
	            <a href="<?php echo $this->url(array('user_id' => $this->featuredVideos[$i]->owner_id, 'video_id' =>  $this->featuredVideos[$i]->video_id,'tab' => $tab_id,'slug' => $this->featuredVideos[$i]->getSlug()),'sitestorevideo_view', true)?>" class="thumb_video">
								<div class="sitestorevideo_thumb_wrapper">
									<?php if ($this->featuredVideos[$i]->duration): ?>
										<span class="sitestore_video_length">
											<?php
											if ($this->featuredVideos[$i]->duration > 360)
											$duration = gmdate("H:i:s", $this->featuredVideos[$i]->duration); else
											$duration = gmdate("i:s", $this->featuredVideos[$i]->duration);
											if ($duration[0] == '0')
											$duration = substr($duration, 1); echo $duration;
											?>
										</span>
									<?php endif; ?>
									<?php  if ($this->featuredVideos[$i]->photo_id): ?>
										<?php echo   $this->itemPhoto($this->featuredVideos[$i], 'thumb.normal'); ?>
									<?php else: ?>
										<img src= "<?php echo $this->layout()->staticBaseUrl ?>application/modules/Sitestorevideo/externals/images/video.png" class="thumb_normal item_photo_video  thumb_normal" />
									<?php endif;?>
								</div>
							</a>
							<span class="show_content_des">
            		<?php
                $owner = $this->featuredVideos[$i]->getOwner();
                //$parent = $this->featuredVideos[$i]->getParent();
                echo 
                     $this->htmlLink($this->featuredVideos[$i]->getHref(), $this->string()->truncate($this->featuredVideos[$i]->getTitle(),25),array('title' => $this->featuredVideos[$i]->getTitle()));
                ?>
								<?php $sitestore_object = Engine_Api::_()->getItem('sitestore_store', $this->featuredVideos[$i]->store_id);?>
								<?php
								$truncation_limit = Engine_Api::_()->getApi('settings', 'core')->getSetting('sitestore.title.truncation', 18);
								$tmpBody = strip_tags($sitestore_object->title);
								$store_title = ( Engine_String::strlen($tmpBody) > $truncation_limit ? Engine_String::substr($tmpBody, 0, $truncation_limit) . '..' : $tmpBody );
								?>
								<?php echo $this->translate("in ") . $this->htmlLink(Engine_Api::_()->sitestore()->getHref($this->featuredVideos[$i]->store_id, $this->featuredVideos[$i]->owner_id, $this->featuredVideos[$i]->getSlug()),  $store_title,array('title' => $sitestore_object->title)) ?>
                <?php if(Engine_Api::_()->getApi('settings', 'core')->getSetting('sitestore.postedby', 0)):?> 
									<?php echo $this->translate('by ').
											$this->htmlLink($owner->getHref(), $this->string()->truncate($owner->getTitle(),25),array('title' => $owner->getTitle()));?>
                <?php endif;?>
            	</span>
	          </div>
         <?php $j++; $offset++; ?>
        <?php if ($j % $this->itemsVisible == 0): ?>
          </div>
        </div>
      <?php endif; ?>
  <?php endfor; ?>
 <?php } ?>
