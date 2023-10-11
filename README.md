## Opportunity Management Automation for Salesforce
Streamline opportunity management post-conversion with automated tasks and a Lightning Web Component for bulk status updates.

## Purpose
Sales teams often overlook closed opportunities after they're converted. This project aims to facilitate a more seamless process for managing these opportunities, ensuring that they're appropriately reviewed and processed.

## Features
Automated Task Creation: Whenever an opportunity is marked as closed/won, a task is automatically created for the record's owner. This task serves as a reminder for the user to review and validate the opportunity details.

Bulk Status Updates via LWC: A user-friendly Lightning Web Component allows users to update the status of multiple opportunities simultaneously, making the management process more efficient.

## Installation
Clone this repository to your local machine.
Deploy the solution to your Salesforce org using Salesforce CLI or a deployment tool of your choice.
Ensure that you've set up the necessary permissions for the components.<br>

**Note:** Before deploying to production, make sure to test in a sandbox or developer environment.

## Usage
<br>

**Task Creation** <br>

Once the trigger is active, any opportunity marked as closed/won will automatically generate a reminder task for the record's owner.
<br>

**Bulk Status Updates**<br>

Navigate to the custom LWC tab in Salesforce.
Select the opportunities you wish to update.
Use the provided interface to modify the status in bulk and submit.
<br>

**Testing**<br>

Navigate to Salesforce's Developer Console.
Run the provided test classes.
Ensure you achieve the necessary code coverage and that all tests pass successfully.
<br>

**Contribution**<br>

Contributions are welcome! Please create a pull request with your proposed changes, and they will be reviewed promptly. Ensure that any modifications maintain or improve the existing code coverage.


## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)
