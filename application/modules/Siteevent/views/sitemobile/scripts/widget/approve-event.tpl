<?php
/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Siteevent
 * @copyright  Copyright 2013-2014 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: request-event.tpl 6590 2014-01-02 00:00:00Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
?>
<script type="text/javascript">
    var eventWidgetRequestSend = function (action, event_id, notification_id, user_id, occurrence_id)
    {
        var url;
        if (action == 'approve')
        {
            url = "<?php echo $this->url(array('controller' => 'member', 'action' => 'approve'), 'siteevent_extended', true) ?>";
        }
        else if (action == 'remove')
        {
            url = "<?php echo $this->url(array('controller' => 'member', 'action' => 'remove', 'ignore_request' => 1), 'siteevent_extended', true) ?>";
        }
        else
        {
            return false;
        }


        $.ajax({
            url: url,
            dataType: 'json',
            data: {
                format: 'json',
                'method': 'post',
                'event_id': event_id,
                'user_id': user_id,
                'format': 'json',
                        'isAjax': 1,
                'occurrence_id': occurrence_id
            },
            error: function () {
            },
            success: function (responseJSON) {
                if (!responseJSON.status)
                {
                    $('#event-widget-approve-' + notification_id).html(responseJSON.error);
                }
                else
                {
                    $('#event-widget-approve-' + notification_id).html(responseJSON.message);
                }
            }
        });

    }
</script>
<?php
$occurrence_id = '';
if (isset($this->notification->params) && isset($this->notification->params['occurrence_id'])) {
    $occurrence_id = $this->notification->params['occurrence_id'];
}
?>
<li id="event-widget-approve-<?php echo $this->notification->notification_id ?>">
    <div class="ui-btn">
        <?php echo $this->itemPhoto($this->notification->getObject(), 'thumb.icon') ?>
        <h3>
            <?php echo $this->translate('%1$s has requested to join the event %2$s.', $this->htmlLink($this->notification->getSubject()->getHref(array('occurrence_id' => $occurrence_id)), $this->notification->getSubject()->getTitle()), $this->htmlLink($this->notification->getObject()->getHref(array('occurrence_id' => $occurrence_id)), $this->notification->getObject()->getTitle())); ?>
        </h3>
        <p>
            <a href="javascript:void(0);" onclick='eventWidgetRequestSend("approve", <?php echo $this->string()->escapeJavascript($this->notification->getObject()->getIdentity()) ?>, <?php echo $this->notification->notification_id ?>, <?php echo $this->notification->getSubject()->getIdentity() ?>, <?php echo $occurrence_id; ?>)'>
                <?php echo $this->translate('APPROVE REQUEST'); ?>
            </a>
            <?php echo $this->translate('or'); ?>
            <a href="javascript:void(0);" onclick='eventWidgetRequestSend("remove", <?php echo $this->string()->escapeJavascript($this->notification->getObject()->getIdentity()) ?>, <?php echo $this->notification->notification_id ?>, <?php echo $this->notification->getSubject()->getIdentity() ?>, <?php echo $occurrence_id; ?>)'>
                <?php echo $this->translate('ignore request'); ?>
            </a>
        </p>
    </div>
</li>