<?php
/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    List
 * @copyright  Copyright 2010-2011 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: index.tpl 2011-05-05 9:40:21Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
?>
<?php 
	$this->headLink()->appendStylesheet($this->layout()->staticBaseUrl
  	              . 'application/modules/Seaocore/externals/styles/styles.css');

?>
<ul class="seaocore_categories_box">
  <li>
    <?php 

$ceil_count = 0;
    $k = 0;
    $list_categories_name = Zend_Registry::isRegistered('list_category_type') ? Zend_Registry::get('list_category_type') : null; ?>
    <?php for ($i = 0; $i < count($this->categories); $i++) { ?>
    <?php if($ceil_count == 0) :?>
      <div>
    <?php endif;?>
    <div class="seaocore_categories_list_col">
      <?php $ceil_count++; ?>
        <?php $category = "";
        if (isset($this->categories[$k]) && !empty($this->categories[$k])): $category = $this->categories[$k];
        endif;
        $k++; ?>
          <?php
          if (empty($category) && !empty($list_categories_name)) {
            break;
          }
          ?>
          <div class="seaocore_categories_list">
            <?php $total_subcat = count($category['sub_categories']) ? count($category['sub_categories']) : 0 ?>
            <h6>
              <?php echo $this->htmlLink($this->url(array('category' => $category['category_id'], 'categoryname' => Engine_Api::_()->getDbTable('categories', 'list')->getCategorySlug($this->translate($category['category_name']))), 'list_general_category'), $this->translate($category['category_name'])) ?>
              <?php if($this->displayNotAll):?>
                (<?php echo $category['count'] ?>)
               <?php endif; ?> 
            </h6>

						<?php if($this->show2ndlevelCategory): ?>
							<div class="sub_cat" id="subcat_<?php echo $category['category_id'] ?>">
								<?php foreach ($category['sub_categories'] as $subcategory) : ?>
									<?php $subcategoryname = '<img src="'. $this->layout()->staticBaseUrl . 'application/modules/List/externals/images/gray_bullet.png" alt="">' . $this->translate($subcategory['sub_cat_name']) ;                 
									if($this->displayNotAll):
										$subcategoryname .= ' (' . ($subcategory['count']) . ')';
									else:
									$subcategoryname .= '';
									endif;
									?>
									<?php echo $this->htmlLink($this->url(array('category' => $category['category_id'], 'categoryname' => Engine_Api::_()->getDbTable('categories', 'list')->getCategorySlug($this->translate($category['category_name'])), 'subcategory' => $subcategory['sub_cat_id'], 'subcategoryname' => Engine_Api::_()->getDbTable('categories', 'list')->getCategorySlug($this->translate($subcategory['sub_cat_name']))), 'list_general_subcategory'), $this->translate($subcategoryname)) ?>
									<?php if(!empty($this->show3rdlevelCategory)):?>
										<?php if(isset($subcategory['tree_sub_cat'])):?>
											<?php foreach ($subcategory['tree_sub_cat'] as $subsubcategory) : ?>
												<?php $subsubcategoryname = '<img src="'. $this->layout()->staticBaseUrl . 'application/modules/List/externals/images/gray_arrow.png" alt="">' . $this->translate($subsubcategory['tree_sub_cat_name']);                                      
									if($this->displayNotAll):
										$subsubcategoryname .= ' (' . ($subsubcategory['count']) . ') ';                
									endif; ?>
												<?php echo $this->htmlLink($this->url(array('category' => $category['category_id'], 'categoryname' => Engine_Api::_()->getDbTable('categories', 'list')->getCategorySlug($this->translate($category['category_name'])), 'subcategory' => $subcategory['sub_cat_id'], 'subcategoryname' => Engine_Api::_()->getDbTable('categories', 'list')->getCategorySlug($this->translate($subcategory['sub_cat_name'])),'subsubcategory' => $subsubcategory['tree_sub_cat_id'], 'subsubcategoryname' => Engine_Api::_()->getDbTable('categories', 'list')->getCategorySlug($this->translate($subsubcategory['tree_sub_cat_name'])),), 'list_general_subsubcategory'), $this->translate($subsubcategoryname)) ?>
											<?php endforeach; ?>
										<?php endif;?>
								<?php endif;?>
								<?php endforeach; ?>
							</div>
						<?php endif; ?>
          </div>
      </div>
     <?php if($ceil_count %3 == 0) :?>
     </div>
     <?php $ceil_count=0; ?>
     <?php endif;?>
    <?php } ?>
  </li>
</ul>