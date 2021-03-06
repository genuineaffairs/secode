<?php

/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Siteevent
 * @copyright  Copyright 2013-2014 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: Map.php 6590 2014-01-02 00:00:00Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
class Siteevent_Form_Admin_Editors_Map extends Engine_Form {

    public function init() {

        $this->setMethod('post');
        $this->setTitle("Remove Editor?")
                ->setAction(Zend_Controller_Front::getInstance()->getRouter()->assemble(array()));

        $this->setDescription('Are you sure want to remove this Editor? If you want to assign editor reviews written by this editor to other editor, then select a new editor from the drop-down below otherwise leave the drop-down blank.');


        $editor_id = Zend_Controller_Front::getInstance()->getRequest()->getParam('editor_id', null);

        $currentEditor = Engine_Api::_()->getItem('siteevent_editor', $editor_id);
        $editorTable = Engine_Api::_()->getDbTable('editors', 'siteevent');

        $getDetails = $editorTable->getEditorDetails($currentEditor->user_id);
        foreach ($getDetails as $getDetail) {
            $multiOptions = array();
            $multiOptions[0] = '';
            $editors = $editorTable->getAllEditors($currentEditor->user_id);
            foreach ($editors as $editor) {
                $user = Engine_Api::_()->getItem('user', $editor->user_id);
                $multiOptions[$editor->user_id] = $user->getTitle();
            }

            $this->addElement('Select', 'editors', array(
                'label' => "Editors",
                'multiOptions' => $multiOptions,
                'value' => '',
            ));
        }

        $this->addElement('Button', 'submit', array(
            'label' => 'Save Changes',
            'type' => 'submit',
            'ignore' => true,
            'decorators' => array('ViewHelper')
        ));

        $this->addElement('Cancel', 'cancel', array(
            'label' => 'cancel',
            'link' => true,
            'prependText' => ' or ',
            'onclick' => 'javascript:parent.Smoothbox.close()',
            'decorators' => array(
                'ViewHelper',
            ),
        ));

        $this->addDisplayGroup(array('submit', 'cancel'), 'buttons');
        $button_group = $this->getDisplayGroup('buttons');
    }

}