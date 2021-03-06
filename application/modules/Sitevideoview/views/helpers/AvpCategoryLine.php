<?php
//  @Reference : 'All-in-one Video - Platinum Edition' by author myseplugins.com
class Sitevideoview_View_Helper_AvpCategoryLine extends Zend_View_Helper_Abstract
{


      public function avpCategoryLine($category_id)
      {
            $categories = Engine_Api::_()->avp()->getCategoryPlusParents($category_id);
            
            $categories_html = array();
            
            foreach ($categories as $category)
            {
                  $categories_html[] = "<form action='".$this->view->url(array(), 'avp_general', true)."' method='post' id='search_category_{$category->category_id}'><input type='hidden' name='category' value='{$category->category_id}' /></form>".
                  $this->view->htmlLink('javascript:void(0);', $category->category_name, array('onClick' => "javascript:$('search_category_{$category->category_id}').submit();", 'style' => 'float: left;'));
            }
            
            $html = array();
            
            for ($i = count($categories_html)-1; $i >= 0; $i--)
            {
                  $html[] = $categories_html[$i];
            }
            
            return implode("<span style='display: inline; float: left;'>&nbsp;&raquo;&nbsp;</span>", $html)."<div style='clear: both; height: 0;'></div>";
      }
      
      
}