# Data Tables
Data table cells need to have their row and column header text spoken to VoiceOver users. Set the `.accessibilityHint`, `.accessibilityValue`, or `.accessibilityLabel` for each cell to include its row and column header text. 

The data table should also have a heading set as the `.accessibilityLabel` for the group. 

Use `.accessibilityElement(children: .contain)` and `.accessibilityLabel("Table Name")` to give the table a group label that is spoken to VoiceOver users when they first focus on a cell in the table.

Notes:

- iOS has no native data table semantics like `<table>`, `<th>`, `<td>`, or `<caption>` elements in HTML, however, there is a native `Table()` element designed only for iPad and macOS which has an accessibility platform defect listed below.

Platform Defects:

- Native `Table()` elements are designed to work only on iPad or macOS and have a platform defect where their row headers are not spoken to VoiceOver when moving between rows.

## Applicable WCAG Success Criteria
- [1.3.1: Info and Relationships](https://www.w3.org/WAI/WCAG22/Understanding/info-and-relationships.html)

## Swift Technique Source Code
[DataTablesView.swift](../iOSswiftUIa11yTechniques/DataTablesView.swift)

----

Copyright 2023-2025 CVS Health and/or one of its affiliates

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0]()

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

See the License for the specific language governing permissions and
limitations under the License.

