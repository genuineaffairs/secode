<?php

/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Sitealbum
 * @copyright  Copyright 2010-2011 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: Level.php 2011-08-026 9:40:21Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
class Sitealbum_Form_Admin_Settings_Level extends Authorization_Form_Admin_Level_Abstract {

  public function init() {
    parent::init();

    // My stuff
    $this
            ->setTitle('Member Level Settings')
            ->setDescription('ALBUM_FORM_ADMIN_LEVEL_DESCRIPTION');

    // Element: view
    $this->addElement('Radio', 'view', array(
        'label' => 'Allow Viewing of Photo Albums?',
        'description' => 'Do you want to let members view albums? If set to no, some other settings on this page may not apply.',
        'multiOptions' => array(
            2 => 'Yes, allow members to view all albums, even private ones.',
            1 => 'Yes, allow viewing and subscription of photo albums.',
            0 => 'No, do not allow photo albums to be viewed.'
        ),
        'value' => ( $this->isModerator() ? 2 : 1 ),
    ));
    if (!$this->isModerator()) {
      unset($this->view->options[2]);
    }

    if (!$this->isPublic()) {

      // Element: create
      $this->addElement('Radio', 'create', array(
          'label' => 'Allow Creation of Photo Albums?',
          'description' => 'Do you want to let members create albums? If set to no, some other settings on this page may not apply. This is useful if you want members to be able to view albums, but only certain levels to be able to create albums.',
          'value' => 1,
          'multiOptions' => array(
              1 => 'Yes, allow creation of photo albums.',
              0 => 'No, do not allow photo albums to be created.'
          ),
          'value' => 1,
      ));

      // Element: edit
      $this->addElement('Radio', 'edit', array(
          'label' => 'Allow Editing of Photo Albums?',
          'description' => 'Do you want to let members of this level edit photo albums?',
          'multiOptions' => array(
              2 => 'Yes, allow members to edit all albums.',
              1 => 'Yes, allow members to edit their own albums.',
              0 => 'No, do not allow photo albums to be edited.',
          ),
          'value' => ( $this->isModerator() ? 2 : 1 ),
      ));
      if (!$this->isModerator()) {
        unset($this->edit->options[2]);
      }

      // Element: delete
      $this->addElement('Radio', 'delete', array(
          'label' => 'Allow Deletion of Photo Albums?',
          'description' => 'Do you want to let members of this level delete photo albums?',
          'multiOptions' => array(
              2 => 'Yes, allow members to delete all photo albums.',
              1 => 'Yes, allow members to delete their own photo albums.',
              0 => 'No, do not allow members to delete their photo albums.',
          ),
          'value' => ( $this->isModerator() ? 2 : 1 ),
      ));
      if (!$this->isModerator()) {
        unset($this->delete->options[2]);
      }

      // Element: comment
      $this->addElement('Radio', 'comment', array(
          'label' => 'Allow Commenting on Photo Albums?',
          'description' => 'Do you want to let members of this level comment on photo albums?',
          'multiOptions' => array(
              2 => 'Yes, allow members to comment on all photo albums, including private ones.',
              1 => 'Yes, allow members to comment on albums.',
              0 => 'No, do not allow members to comment on photo albums.',
          ),
          'value' => ( $this->isModerator() ? 2 : 1 ),
      ));
      if (!$this->isModerator()) {
        unset($this->comment->options[2]);
      }

      // Element: comment
      $this->addElement('Radio', 'rate', array(
          'label' => 'Allow Rating on Photo Albums?',
          'description' => 'Do you want to let members of this level rate on photos / albums?',
          'multiOptions' => array(
              1 => 'Yes, allow members to rate on photos / albums.',
              0 => 'No, do not allow members to rate on photos / albums.',
          ),
          'value' => 1,
      ));
      
        // Element: comment
      $this->addElement('Radio', 'album_password_protected', array(
          'label' => "Allow Password Protection on Photo Albums?",
          'description' => "Do you want to let members of this level to protect their photos / albums with password?",
          'multiOptions' => array(
              1 => 'Yes, allow members to protect their photos / albums with password.',
              0 => 'No, do not allow members to protect their photos / albums with password.',
          ),
          'value' => 1,
      ));

      // Element: auth_view
      $this->addElement('MultiCheckbox', 'auth_view', array(
          'label' => 'Album Privacy',
          'description' => 'ALBUM_FORM_ADMIN_LEVEL_AUTHVIEW_DESCRIPTION',
          'multiOptions' => array(
              'everyone' => 'Everyone',
              'registered' => 'All Registered Members',
              'owner_network' => 'Friends and Networks',
              'owner_member_member' => 'Friends of Friends',
              'owner_member' => 'Friends Only',
              'owner' => 'Just Me'
          ),
          'value' => array('everyone', 'owner_network', 'owner_member_member', 'owner_member', 'owner'),
      ));

      // Element: auth_comment
      $this->addElement('MultiCheckbox', 'auth_comment', array(
          'label' => 'Album Comment Options',
          'description' => 'ALBUM_FORM_ADMIN_LEVEL_AUTHCOMMENT_DESCRIPTION',
          'multiOptions' => array(
              'everyone' => 'Everyone',
              'registered' => 'All Registered Members',
              'owner_network' => 'Friends and Networks',
              'owner_member_member' => 'Friends of Friends',
              'owner_member' => 'Friends Only',
              'owner' => 'Just Me'
          ),
          'value' => array('everyone', 'owner_network', 'owner_member_member', 'owner_member', 'owner'),
      ));

      // Element: auth_tag
      $this->addElement('MultiCheckbox', 'auth_tag', array(
          'label' => 'Album Tag Options',
          'description' => 'ALBUM_FORM_ADMIN_LEVEL_AUTHTAG_DESCRIPTION',
          'multiOptions' => array(
              'everyone' => 'Everyone',
              'registered' => 'All Registered Members',
              'owner_network' => 'Friends and Networks',
              'owner_member_member' => 'Friends of Friends',
              'owner_member' => 'Friends Only',
              'owner' => 'Just Me'
          ),
          'value' => array('everyone', 'owner_network', 'owner_member_member', 'owner_member', 'owner'),
      ));
    }
  }

}