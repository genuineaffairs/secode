<?php
/**
 * SocialEngine
 *
 * @category   Application_Extensions
 * @package    Siteiosapp
 * @copyright  Copyright 2015-2016 BigStep Technologies Pvt. Ltd.
 * @license    http://www.socialengineaddons.com/license/
 * @version    index.tpl 2015-10-01 00:00:00Z SocialEngineAddOns $
 * @author     SocialEngineAddOns
 */
?>
<h2>
    <?php echo $this->translate('iOS Mobile Application - iPhone and iPad') ?>
</h2>
<?php if (count($this->navigation)): ?>
    <div class='seaocore_admin_tabs'>
        <?php
        // Render the menu
        echo $this->navigation()->menu()->setContainer($this->navigation)->render()
        ?>
    </div>
<?php endif; ?>

<br />
<h3>
    Please read & follow the below important instructions for building your iOS App
</h3>
<p>
    Below are the steps to help you with providing your iOS App's details for building and submitting the app to app store. Please read them carefully and follow them.
</p>
<br />
<div class="admin_seaocore_files_wrapper">
    <ul class="admin_seaocore_files seaocore_faq">
        <li>
            <?php 
                echo '<p>Not purchased our Mobile Apps Subscription Plans yet? Please do so from here: <br /><a href="http://www.socialengineaddons.com/socialengine-ios-iphone-android-mobile-apps-subscriptions" target="_blank">http://www.socialengineaddons.com/socialengine-ios-iphone-android-mobile-apps-subscriptions</a>.</p>'
            . '<br /><p>The only difference between our "Mobile Starter Plan" and "Mobile Pro Plan" is that the Mobile Pro plan enables you to submit the app to app store with your own app store developer account, whereas with the Mobile Starter Plan, it gets submitted with our SocialEngineAddOns developer account.</p>';
            ?>
        </li>

        <li>
            <?php echo '<p>Fill the "App Submission Details" form with information specific to your app, like App Title, Description, branding information, etc, by clicking on the "Proceed to iOS App Setup" button at the bottom of this page.</p><br /><p><span style="font-weight: bold;">Note:</span>If you have subscribed to the "Mobile Pro Plan", then you will also need to provide us your Apple iOS Developer Account Details. If you have not yet enrolled into the iOS Developer Program, then please enroll from here: <a href="https://developer.apple.com/programs" target="_blank">https://developer.apple.com/programs</a>.</p>'; ?>
        </li>
        
        <li>
            <?php 
                echo '<p>After filling ALL the App Submission Details, please save the form. Then, you will see a "Download tar" link at the bottom of the page. Please click on it to download the compressed tar file with your app\'s details, and email that file to us as an attachment at: <a href="mailto: apps@socialengineaddons.com">apps@socialengineaddons.com</a>, with email subject as the one that will be shown to you in the download popup.</p>';
            ?>
        </li>
        
        <li>
            <?php echo '<p>Then, please initiate a Support Ticket from your SocialEngineAddOns Client Area by choosing the Product as: "iOS Mobile Application", subject as: "iOS App Build and Setup", and send us the FTP and Admin details of your website from it. This will enable our support team to start work on your App\'s creation.</p>'; ?>
        </li>

        <br />
        <span style="font-weight: bold;">Note:</span> We will be submitting your iOS App to the Apple iTunes App Store within 24 to 72 hours of receiving ALL the details and support ticket from you. <br /><br />
        While submitting your App to the App Store, we will take and post good screenshots of your App for the App listing. If you have the "Mobile Pro Plan", then:
        <br />
        - You will be able to change them easily as per your choice from your Apple iTunes Developer Account.<br />
        - After your App is submitted, then you will also be able to add additional graphics for it from your developer account.
        <br /><br />
        We recommend you to go through Apple's App Store Review Guidelines: <a href="https://developer.apple.com/app-store/review/guidelines" target="_blank">https://developer.apple.com/app-store/review/guidelines</a> to see what all content is permissible for your iOS app.
        <br /><br />
        <center>
            <button onclick="form_submit();"><?php echo 'Proceed to iOS App Setup'; ?> </button>
        </center>
        <br />
        </li>
    </ul>
</div>

<script type="text/javascript" >
    function form_submit() {
        var url = '<?php echo $this->url(array('module' => 'siteiosapp', 'controller' => 'app-builder', 'action' => 'create'), 'admin_default', true) ?>';
        window.location.href = url;
    }
</script>