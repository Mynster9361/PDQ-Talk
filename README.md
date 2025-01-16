# Microsoft Graph API PowerShell Samples

This repository contains a series of PowerShell scripts that demonstrate how to interact with the Microsoft Graph API. Each sample covers a different aspect of authentication and API usage, providing practical examples and best practices.

## Table of Contents

- [Introduction](#introduction)
- [Samples](#samples)
  - [Sample1.0_AuthDeviceCode.ps1](#sample10_authdevicecodeps1)
  - [Sample1.1_AuthSecret.ps1](#sample11_authsecretps1)
  - [Sample1.2_AuthCertificate.ps1](#sample12_authcertificateps1)
  - [Sample2.0_ApiCallDeviceCode.ps1](#sample20_apicalldevicecodeps1)
  - [Sample2.1_ApiCall_ClientSecret.ps1](#sample21_apicall_clientsecretps1)
  - [Sample3_NextPage.ps1](#sample3_nextpageps1)
  - [Sample4_Throtling.ps1](#sample4_throtlingps1)
  - [Sample5_Filter.ps1](#sample5_filterps1)
  - [Sample6_Search.ps1](#sample6_searchps1)
  - [Sample7_AdvancedFilters.ps1](#sample7_advancedfiltersps1)
  - [Sample8_BatchRequests.ps1](#sample8_batchrequestsps1)

## Introduction

This series of sample scripts demonstrates how to interact with the Microsoft Graph API using PowerShell. Each sample covers a different aspect of authentication and API usage, providing practical examples and best practices.

## Samples

### Sample1.0_AuthDeviceCode.ps1

Demonstrates how to authenticate using the device code flow. This method is useful for scenarios where a user needs to authenticate interactively on a device that doesn't have a browser.

### Sample1.1_AuthSecret.ps1

Demonstrates how to authenticate using a client secret. This method is suitable for server-to-server communication where a client secret is used to authenticate the application.

### Sample1.2_AuthCertificate.ps1

Demonstrates how to authenticate using a certificate. This method is more secure than using a client secret and is suitable for scenarios where enhanced security is required.

### Sample2.0_ApiCallDeviceCode.ps1

Demonstrates how to make an API call using the device code flow. This script shows how to retrieve data from the Microsoft Graph API after authenticating with the device code flow.

### Sample2.1_ApiCall_ClientSecret.ps1

Demonstrates how to make an API call using a client secret. This script shows how to retrieve data from the Microsoft Graph API after authenticating with a client secret.

### Sample3_NextPage.ps1

Demonstrates how to handle pagination when retrieving data from the API. This script shows how to handle scenarios where the API returns paginated results and how to retrieve all pages of data.

### Sample4_Throtling.ps1

Demonstrates how to handle throttling when making API calls. This script shows how to implement retry logic to handle throttling responses from the API and avoid hitting rate limits.

### Sample5_Filter.ps1

Demonstrates how to use filters to retrieve specific data from the API. This script shows how to apply OData filters to API requests to retrieve only the data that meets certain criteria.

### Sample6_Search.ps1

Demonstrates how to use the search functionality to find data in the API. This script shows how to use the search query parameter to perform searches within the Microsoft Graph API.

### Sample7_AdvancedFilters.ps1

Demonstrates how to use advanced filters to retrieve data from the API. This script shows how to apply complex OData filters to API requests to retrieve data based on advanced criteria.

### Sample8_BatchRequests.ps1

Demonstrates how to make batch requests to the API. This script shows how to combine multiple API requests into a single batch request to improve efficiency and reduce the number of HTTP calls.

## Getting Started

To run these samples, you will need to have PowerShell installed on your machine. You will also need to register an application in Azure AD and obtain the necessary credentials (tenant ID, client ID, client secret, and certificate) depending on your authentication scenario to authenticate with the Microsoft Graph API.

## Contributing

If you have any suggestions or improvements for these samples, feel free to submit a pull request or open an issue.
