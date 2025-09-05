# Containers

Containers can group sections of a page with meaningful accessible names. VoiceOver users can jump between each container using the Rotor. Containers can group related controls like radio buttons or mimic the behavior of ARIA Landmarks. The container name is spoken to VoiceOver when focus is first placed on an element inside the group. 

Use `.accessibilityElement(children: .contain)` on the group container element and `.accessibilityLabel` to give the group a meaningful label for VoiceOver users.
                
## Applicable WCAG Success Criteria
- [1.3.1: Info and Relationships](https://www.w3.org/WAI/WCAG22/Understanding/info-and-relationships.html)
- [2.4.1: Bypass Blocks](https://www.w3.org/WAI/WCAG22/Understanding/bypass-blocks.html)

## Swift Technique Source Code
[ContainersView.swift](../iOSswiftUIa11yTechniques/ContainersView.swift)

----

Copyright 2025 CVS Health and/or one of its affiliates

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0]()

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

See the License for the specific language governing permissions and
limitations under the License.
