<?php 
/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    goals
 * @copyright  Copyright 2014 Stars Developer
 * @license    http://www.starsdeveloper.com 
 * @author     Stars Developer
 */
?>
<form method="post" class="global_form_popup">
    <div>
      <h3><?php echo $this->translate("Delete Goal Template Task?") ?></h3>
      <p>
        <?php echo $this->translate("Are you sure that you want to delete this goal template task? It will not be recoverable after being deleted.") ?>
      </p>
      <br />
      <p>
        <input type="hidden" name="confirm" value="<?php echo $this->goal_id?>"/>
        <button type='submit'><?php echo $this->translate("Delete") ?></button>
        <?php echo $this->translate("or") ?>
        <a href='javascript:void(0);' onclick='javascript:parent.Smoothbox.close()'>
        <?php echo $this->translate("cancel") ?></a>
      </p>
    </div>
  </form>

<?php if( @$this->closeSmoothbox ): ?>
<script type="text/javascript">
  TB_close();
</script>
<?php endif; ?>
