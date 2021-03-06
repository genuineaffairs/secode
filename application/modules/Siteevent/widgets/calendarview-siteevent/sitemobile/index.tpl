<?php
/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Siteevent
 * @copyright  Copyright 2013-2014 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    $Id: index.tpl 6590 2014-01-02 00:00:00Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */ 
?>
<?php if ($this->viewtype == 'calendar') : ?>

<script type="text/javascript">

  var calendar_params = <?php echo Zend_Json_Encoder::encode($this->params); ?>;
     // function to switch to next and last months through ajax request - siteevent
  function another_month(date_current) {
//      $.mobile.showPageLoadingMsg(); 
      $.mobile.loading("show");
      var data_another_month = $.extend(calendar_params,{
          'date_current': date_current,
          'format': 'html',
          'is_ajax': true,

      });
      $.ajax({
          'url': sm4.core.baseUrl + 'widget/index/mod/siteevent/name/calendarview-siteevent',
          'data': data_another_month,
          'force':true,
          success: function(responseHTML) {
//            $.mobile.hidePageLoadingMsg();
            $.mobile.loading("hide");
            $.mobile.activePage.find('#dyanamic_code').html(responseHTML);
            sm4.core.dloader.refreshPage();
            sm4.core.runonce.trigger();
          }
      });
  }
    <?php if (empty($this->isajax)): ?> 
    var eventslistlocationbaseddelay = 0;
       sm4.core.runonce.add(function() { 
           <?php if($this->loaded_by_ajax):?>
           another_month('<?php echo $this->date_current;?>');
           eventslistlocationbaseddelay = 2000;
           <?php endif;?>
        <?php if($this->detactLocation):?>
            setTimeout(function() { 
             var requestParams = $.extend(<?php echo json_encode($this->params); ?>, {'content_id': '<?php echo $this->identity; ?>', 'is_ajax': true, 'date_current': '<?php echo $this->date_current;?>'})
            var params = {
                'detactLocation': <?php echo $this->detactLocation; ?>,
                'responseContainer': 'dyanamic_code',
                requestParams: requestParams
            };  
            sm4.core.locationBased.startReq(params);
      },eventslistlocationbaseddelay);
       <?php endif;?>
        }); 
     <?php endif;?>

</script>

    <?php if (empty($this->isajax)): ?>
    <div id = "event_list_content" style="display: none;"></div>
        <div class="siteevent_mini_calendar_wrapper" id="dyanamic_code">
        <?php endif; ?>
        <!--CASE1: WHEN ADMIN SETTING IS TO SHOW ONLY TITLE-->

        <!--CASE2: WHEN ADMIN SETTING IS TO SHOW ONLY PHOTO-->

        <!--CASE3: WHEN ADMIN SETTING IS TO SHOW TITLE WITH PHOTO-->

        <!--CASE4: WHEN ADMIN SETTING IS TO SHOW CALENDER-->
        <?php if (1) : ?>

            <?php $date_last = $this->date_last; ?>
            <?php $date_next = $this->date_next; ?>

            <div id="calender" class="siteevent_mini_calendar siteevent_calendar b_medium br_body_bg">
                <div class="caption b_medium">
                    <div class="pre fleft">
                        <?php
                        $ajax_month = $this->current_month;
                        $prev_array = array();
                        $next_array = array();
                        $array_incr = 12;
                        while ($array_incr > date('m', time()) + 1) {
                            $prev_array[] = $array_incr;
                            $array_incr = $array_incr - 1;
                        }
                        $array_incr = 1;
                        while ($array_incr < date('m', time()) - 1) {
                            $next_array[] = $array_incr;
                            $array_incr = $array_incr + 1;
                        }
                        ?>
                        <?php if ($this->current_year >= date('Y', time()) || ($this->current_year == date('Y', time()) - 1 && in_array($ajax_month, $prev_array))) :
                            ?>
                            <a href='javascript:void(0);'  onclick = 'another_month(<?php echo $date_last ?>)' title="<?php echo $this->translate('Previous') ?>"><?php echo $this->translate("&laquo;"); ?></a>
                        <?php endif; ?>
                    </div>
                    <div class="nxt fright">
                        <?php if ($this->current_year <= date('Y', time()) || ($this->current_year == date('Y', time()) + 1 && in_array($ajax_month, $next_array))) :
                            ?>
                            <a href='javascript:void(0);' onclick = 'another_month(<?php echo $date_next ?>)' title="<?php echo $this->translate('Next') ?>"><?php echo $this->translate("&raquo;"); ?></a>
                        <?php endif; ?>
                    </div>
                    <div class="month_name o_hidden">
                        <?php echo $this->translate($this->current_month_text); ?><?php echo ",\t" . $this->current_year; ?>
                    </div>
                </div>
                <table cellpadding="0" cellspacing="0">

                    <?php $day_start = Engine_Api::_()->getApi('settings', 'core')->getSetting('seaocore.calendar.daystart', 1);
                    ?>
                    <tr class="b_medium siteevent_min_calendar_dname">
                        <?php if ($day_start == 1) : ?>
                            <td class='b_light' title="<?php echo $this->translate('SITEEVENT_DAY_SUNDAY') ?>"><div class="day"><?php
                                    echo
                                    $this->translate("SITEEVENT_DAY_SUN")
                                    ?></div></td>
                        <?php elseif ($day_start == 3): ?>

                            <td class='b_light' title="<?php echo $this->translate('SITEEVENT_DAY_SATURDAY') ?>"><div class="day"><?php
                                    echo
                                    $this->translate("SITEEVENT_DAY_SAT")
                                    ?></div></td>
                            <td class='b_light' title="<?php echo $this->translate('SITEEVENT_DAY_SUNDAY') ?>"><div class="day"><?php
                        echo
                        $this->translate("SITEEVENT_DAY_SUN")
                        ?></div>
                            </td>

                        <?php endif; ?>
                        <td class='b_light' title="<?php echo $this->translate('SITEEVENT_DAY_MONDAY') ?>"><div class="day"><?php
                                echo
                                $this->translate("SITEEVENT_DAY_MON");
                                ?></div>
                        </td>
                        <td class='b_light' title="<?php echo $this->translate('SITEEVENT_DAY_TUESDAY') ?>"><div class="day"><?php
                                echo
                                $this->translate("SITEEVENT_DAY_TUES")
                                ?></div>
                        </td>
                        <td class='b_light' title="<?php echo $this->translate('SITEEVENT_DAY_WEDNESDAY') ?>"><div class="day"><?php
                        echo
                        $this->translate("SITEEVENT_DAY_WED")
                                ?></div>
                        </td>
                        <td class='b_light' title="<?php echo $this->translate('SITEEVENT_DAY_THURSDAY') ?>"><div class="day"><?php
                echo
                $this->translate("SITEEVENT_DAY_THUR")
                                ?></div>
                        </td>
                        <td class='b_light' title="<?php echo $this->translate('SITEEVENT_DAY_FRIDAY') ?>"><div class="day"><?php
                        echo
                        $this->translate("SITEEVENT_DAY_FRI")
                        ?></div>
                        </td>
                        <?php if ($day_start != 3) : ?>
                            <td class='b_light' title="<?php echo $this->translate('SITEEVENT_DAY_SATURDAY') ?>"><div class="day"><?php
                echo
                $this->translate("SITEEVENT_DAY_SAT")
                                    ?></div>
                            </td>
                        <?php endif; ?>
                        <?php if ($day_start == 2) : ?>
                            <td class='b_light' title="<?php echo $this->translate('SITEEVENT_DAY_SUNDAY') ?>"><div class="day"><?php
                        echo
                        $this->translate("SITEEVENT_DAY_SUN")
                        ?></div></td>
                        <?php endif; ?>
                    </tr>
                    <?php
                    $i = 1;
                    $date = 1;
                    $empty = 1;
                    $flag = 0;
                    ?>
                    <?php
                    if ($day_start == 1) {
                        $this->first_day_of_month++;
                        $this->last_day_of_month++;
                    } elseif ($day_start == 3) {
                        $this->first_day_of_month = $this->first_day_of_month + 2;
                        $this->last_day_of_month = $this->last_day_of_month + 2;
                    }
                    ?>
                    <?php $total_cells = $this->total_cells ?>
                    <?php $total_month_birthcount = 0; ?>
                    <?php while ($total_cells > 0) : ?>
                        <?php
                        $entry_counter = 0;
                        $tooltip_string = "";
                        $div_active = 0;
                        ?>
                        <?php if (($i - 1) % 7 == 0) { ?>
                            <tr class="b_medium">
                        <?php } ?>
                        <?php if (1) : ?>
                            <td class="b_light">
                                <?php
                                $date_entry = 0;
                                $days_count = 1;
                                ?>
                                <?php if ($i >= $this->first_day_of_month && $i <= $this->last_day_of_month) : ?>
                                    <?php //if($february_flag == 1) { $february_last_entry = 1; }?>
                                    <?php $flaghead = false; ?>
                                    <?php
                                    //GET THE EVENT START DATE WITH IN THIS MONTH
                                    $dayEventCount = '';
                                    ?>
                                    <?php if (!empty($this->monthEventResults) && array_key_exists($date, $this->monthEventResults)) : ?>
                                        <?php if ($div_active == 0) : ?>
                                            <?php
                                                $currentdate = strtotime($this->current_year . '/' . $this->current_month . '/' . $date);
                                                if ($date == date('d', time()) && $this->current_month == date('m', time())) :
                                                    ?>
                                            <div id='view_<?php echo $date ?>' class="day current_date prelative" onclick="getDayEvents(<?php echo $currentdate; ?>);">
                                                    <?php
                                                    $dayEventCount = '<span class="events_counts">' . $this->monthEventResults[$date] . '</span>';
                                                    $div_active++;
                                                    ?>
                                                <?php else : ?>
                                                <div id='view_<?php echo $date ?>' class="active day prelative" onclick="getDayEvents(<?php echo $currentdate; ?>);"> 
                                                    <?php
                                                    $dayEventCount = '<span class="events_counts">' . $this->monthEventResults[$date] . '</span>';
                                                    $div_active++;
                                                    ?>
                                                <?php endif; ?>
                                            <?php endif; ?>
                                        <?php else : ?>
                                        <?php endif; ?>
                                        <?php $empty = 0;
                                        $days_count++;
                                        ?>
                                        <?php
                                        if ($entry_counter == 0) {
                                            $currentdate = strtotime($this->current_year . '/' . $this->current_month . '/' . $date);
                                            if (empty($dayEventCount)):
                                                if ($date == date('d', time()) && $this->current_month == date('m', time()))
                                                    echo '<div class="current_date day" onclick="getDayEvents(' . $currentdate . ');">';
                                                else
                                                    echo "<div class='day'>";
                                            endif;
                                            echo $date;
                                            //CHECK THE ADMIN SETTING TO SHOW THE EVENTS COUNT.
                                            if (isset($this->params['siteevent_calendar_event_count']) && !empty($this->params['siteevent_calendar_event_count']))
                                                echo $dayEventCount;

                                            if (empty($dayEventCount)):
                                                echo "</div>";
                                            endif;
                                        }
                                        $date = $date + 1;
                                        ?>

                                    </div>
                                <?php endif; ?>
                            </td>
                        <?php else : ?>
                            <td class="b_light">&nbsp;</td>
                        <?php endif; ?>
                        <?php if ($i % 7 == 0) { ?>
                                    </tr>
                        <?php } ?>
                        <?php $i = $i + 1; ?>
                        <?php $total_cells = $total_cells - 1; ?>
                    <?php endwhile; ?>
                </table>
            </div>
    <?php endif; ?>
    <?php if (empty($this->isajax)): ?>
        </div>
    <?php endif; ?>

    <?php
else :
    //INCLUDE THE REPETE EVENT HTML FILE WHICH WILL BE HIDE ON THIS PAGE
    include APPLICATION_PATH . '/application/modules/Siteevent/views/sitemobile/scripts/_calendarEventList.tpl';

endif;
?>
