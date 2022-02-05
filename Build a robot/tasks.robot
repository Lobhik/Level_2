*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Library    RPA.Browser.Selenium    auto_close=${FALSE}
Library    RPA.Excel.Files
Library    RPA.Tables
Library    RPA.PDF
Library    RPA.Dialogs
Library    RPA.Robocorp.Vault
Library    RPA.Archive

*** Variables ***
 

*** Tasks ***

Orders robots from RobotSpareBin Industries Inc
 
    Open the intranet website
    Fill the form using the data from the CSV file
    Create a ZIP file of the receipts
    ${Secrets} =     Get Secret    robotsparebin
    Log To Console          Getting Secret from our Vault
    Log                     ${Secrets}[username] wrote this program for you      console=yes
    
    Add heading             I am your RoboCorp Order ${Secrets}[username]
    Add text input          myname    label=What is your name?     placeholder=Give me some input here
    ${result}=              Run dialog

    





*** Keywords ***
        
Open the intranet website
     Open Available Browser    https://robotsparebinindustries.com/#/robot-order
     
    
Close the annoying modal
     Click Element When Visible    css:.alert-buttons button
   

     
Filling the form
    Set Local Variable    ${order}    id:order
    
     [Arguments]    ${lobhik}     
     
     Select From List By Value    head    ${lobhik}[Head]
     Select Radio Button    body    ${lobhik}[Body]
     Input Text    css:.form-control    ${lobhik}[Legs]
     Input Text    address    ${lobhik}[Address]


Preview the robot
  
    
     Click Button    Preview
     
     

     Click Button    Order
     ${Visible}    Is Element Visible    css:.alert-danger
     IF    ${Visible} == True
         Double Click Element    id:order
         IF    ${Visible} == True
             Click Element If Visible    id:order
             
         END    
         
     END
     
     
     Wait Until Page Contains Element    id:order-completion

     
Store the receipt as a PDF file
    [Arguments]    ${order_number}
    ${receipt_html} =    Get Element Attribute    id:receipt    outerHTML
    Set Local Variable    ${file_path}    ${OUTPUT_DIR}${/}receipt_${order_number}.pdf
    Html To Pdf    ${receipt_html}    ${file_path}
    [Return]    ${file_path}


Take a screenshot of the robot
    [Arguments]    ${scr}
     Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}robot_${scr}.png
     Set Local Variable    ${screen}    ${OUTPUT_DIR}${/}robot_${scr}.png
     [Return]    ${screen}


Go to order another robot   
     Click Button    id:order-another
     
  



Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}

    Set Local Variable    ${new_pdf}   ${OUTPUT_DIR}${/}result.pdf

    ${Files} =    Create List
    ...    ${pdf}
    ...    ${screenshot}
    Add Files To Pdf    ${Files}    ${new_pdf}    append=True       



Fill the form using the data from the CSV file
    ${Orders}=    Read table from CSV    orders.csv    header=True    
   
    FOR    ${lobhik}    IN    @{Orders}
        Close the annoying modal
        Filling the form    ${lobhik}
        Preview the robot
        ${pdf} =    Store the receipt as a PDF file    ${lobhik}[Order number]    
        ${screenshot} =    Take a screenshot of the robot    ${lobhik}[Order number]   
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}   
        Go to order another robot
        
    END

Create a ZIP file of the receipts
    
    Set Local Variable    ${receipt_dir}     ${OUTPUT_DIR}${/}recipts
    ${zip_file_name} =    Set Variable    ${OUTPUT_DIR}${/}all_receipts.zip
    Archive Folder With Zip    ${OUTPUT_DIR}${/}    ${zip_file_name}



Saves the order HTML receipt as a PDF file
    Click Button When Visible    Order another robot
 

