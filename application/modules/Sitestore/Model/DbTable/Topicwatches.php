<?php

/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Sitestore
 * @copyright  Copyright 2012-2013 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: Topicwatches.php 2013-09-02 00:00:00Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
class Sitestore_Model_DbTable_Topicwatches extends Engine_Db_Table {

   /**
   * Return topic is watchable or not
   *
   * @param int $resource_id
   * @param int $topic_id
   * @param int $user_id
   * @return watch
   */
  public function isWatching($resource_id, $topic_id, $user_id) {

    $isWatching =   $this->select()
      ->from($this->info('name'), 'watch')
      ->where('resource_id = ?', $resource_id)
      ->where('topic_id = ?', $topic_id)
      ->where('user_id = ?', $user_id)
      ->limit(1)
      ->query()
      ->fetchColumn(0)
      ;

    return $isWatching;
  }

  /**
   * Return user id
   *
   * @param array $params
   * @return user id
   */
  public function getNotifyUserIds($params=array()) {

    return $this->select()
        ->from($this->info('name'), 'user_id')
        ->where('resource_id = ?', $params['store_id'])
        ->where('topic_id = ?', $params['topic_id'])
        ->where('watch = ?', 1)
        ->query()
        ->fetchAll(Zend_Db::FETCH_COLUMN);
  }

}
?>