# Sliders
Sliders are used to adjust a value by sliding the thumb between the minimum and maximum. VoiceOver users must hear the slider accessibility label and "adjustable" trait as well as be able to adjust the value by swiping up or down.

Use `Slider` to create a native slider control that is adjustable with VoiceOver. 

Give each `Slider` a unique and specific accessibility label using `.accessibilityLabel` and visible label `Text`. 

Provide single tap alternatives to adjusting the slider with a gesture.

Notes:

- Include a `TextField` and `Stepper` to allow users fine control when adjusting the slider value.

## Applicable WCAG Success Criteria
- [4.1.2: Name, Role, Value](https://www.w3.org/WAI/WCAG22/Understanding/name-role-value.html)
- [2.5.1: Pointer Gestures](https://www.w3.org/WAI/WCAG22/Understanding/pointer-gestures)

## WCAG Sufficient Techniques
- [G216: Providing single point activation for a control slider](https://www.w3.org/WAI/WCAG21/Techniques/general/G216)


----

Copyright 2023-2024 CVS Health and/or one of its affiliates

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
[http://www.apache.org/licenses/LICENSE-2.0]()

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

See the License for the specific language governing permissions and
limitations under the License.
