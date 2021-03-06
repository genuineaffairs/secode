<?php
/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Store
 * @copyright  Copyright Hire-Experts LLC
 * @license    http://www.hire-experts.com
 * @version    $Id: Upload.php 08.09.11 11:29 taalay $
 * @author     Taalay
 */

/**
 * @category   Application_Extensions
 * @package    Store
 * @copyright  Copyright Hire-Experts LLC
 * @license    http://www.hire-experts.com
 */

class Store_Form_Admin_Video_Upload extends Engine_Form
{
  public function init()
  {

    // Init form
    $this
      ->setAttrib('id', 'form-upload')
      ->setAttrib('name', 'video_create')
      ->setAttrib('enctype','multipart/form-data');

    $user = Engine_Api::_()->user()->getViewer();

    // Init name
    $this->addElement('Text', 'title', array(
      'label' => 'Video Title',
      'maxlength' => '100',
      'allowEmpty' => false,
      'required' => true,
      'filters' => array(
        //new Engine_Filter_HtmlSpecialChars(),
        'StripTags',
        new Engine_Filter_Censor(),
        new Engine_Filter_StringLength(array('max' => '100')),
      )
    ));

    // Init descriptions
    $this->addElement('Textarea', 'description', array(
      'label' => 'Video Description',
      'filters' => array(
        'StripTags',
        new Engine_Filter_Censor(),
        //new Engine_Filter_HtmlSpecialChars(),
        new Engine_Filter_EnableLinks(),
      ),
    ));

      $t = new Engine_Form_Element_Radio('type');
      $opts = array(
          1 => 'Service(Youtube, Vimeo)',
          3 => 'Desktop'
      );
      $t->setValue(1)
          ->setMultiOptions($opts)
          ->setLabel('Type')
          ->setDecorators(array('ViewHelper'));
      $this->addElement($t);

      // Init url
      $this->addElement('Text', 'url', array(
          'label' => 'Video Link (URL)',
          'description' => 'Paste the web address of the video here.',
          'maxlength' => '50'
      ));
      $this->url->getDecorator("Description")->setOption("placement", "append");

      $this->addElement('Hidden', 'code', array(
          'order' => 1
      ));
      $this->addElement('Hidden', 'product_id', array(
          'order' => 2
      ));
      $this->addElement('Hidden', 'ignore', array(
          'order' => 3
      ));

      $this->addElement('Hidden', 'video_id', array(
          'validators' => array(
              'Int',
          )
      ));


      $fancyUpload = new Engine_Form_Element_FancyUpload('file');

      $fancyUpload->clearDecorators()
          ->addDecorator('FormFancyUpload')
          ->addDecorator('viewScript', array(
              'viewScript' => '_FancyUpload2.tpl',
              'placement'  => '',
          ));
      Engine_Form::addDefaultDecorators($fancyUpload);
      if($this->video && $this->video->type == 3) {
          $fancyUpload->setAttrib('style', 'display: none;');
      } else {
          $fancyUpload->setAttrib('style', 'display: block;');
      }
      $this->addElement($fancyUpload);

      $remove = new Engine_Form_Element_Button('remove');
      $remove->setLabel('Remove Video')->setDecorators(array('ViewHelper'));
      if(!$this->video) {
          $remove->setAttrib('style', 'display: none;');
      }

      $submit = new Engine_Form_Element_Button('upload');
      $submit->setLabel('Save')->setDecorators(array('ViewHelper'));

      $this->addDisplayGroup(
          array($remove, $submit),
          'video_controls',
          array()
      );

      $content = ($this->video) ? $this->video->getRichContent(1): '';

      $this->addElement('Dummy', 'preview', array(
          'content' => "<div><div id='store-video-preview'>{$content}</div><div style='display: none;' id='video-loader' class='he-loader-animation'></div></div>"
      ));
  }

}
