<?php

/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Siteevent
 * @copyright  Copyright 2013-2014 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: Request.php 6590 2014-01-02 00:00:00Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
class Siteevent_Form_Member_Request extends Engine_Form {

    public function init() {
        $this
                ->setTitle('Request Event Membership')
                ->setDescription('Would you like to request membership in this Event?')
                ->setMethod('POST')
                ->setAction($_SERVER['REQUEST_URI'])
        ;

        //$this->addElement('Hash', 'token');

        $this->addElement('Button', 'submit', array(
            'label' => 'Send Request',
            'ignore' => true,
            'decorators' => array('ViewHelper'),
            'type' => 'submit'
        ));

        $this->addElement('Cancel', 'cancel', array(
            'prependText' => ' or ',
            'label' => 'cancel',
            'link' => true,
            'href' => '',
            'onclick' => 'parent.Smoothbox.close();',
            'decorators' => array(
                'ViewHelper'
            ),
        ));

        $this->addDisplayGroup(array(
            'submit',
            'cancel'
                ), 'buttons');
    }

}