# Interaction pattern catalog

Use the named pattern only when it improves the user action. Its values are starting points, not visual requirements.

## Source note

Patterns 8–17 were adapted from the user-provided interaction brief, with the source video recorded as: [用大白话向 AI 描述 10 种 App/小程序高级动画指令](https://www.bilibili.com/video/BV1gAtm69ER4). The rules below are the implementation contract for this workflow.

## 1. Interactive back navigation

**Use for:** moving from a detail back to its parent while preserving spatial context.

- Start from the platform back edge or an explicit back affordance.
- Move the outgoing page with the gesture; reveal the parent continuously beneath it.
- Commit after a meaningful horizontal distance or release velocity; otherwise return to the detail without changing its state.
- Keep vertical scrolling and horizontal content carousels from accidentally triggering a route pop.
- Fallback: visible Back control and native platform Back action.

## 2. Press with cancellation

**Use for:** high-consequence or momentary actions where the person needs a chance to abort before release.

- On press down, show the armed state immediately: surface depth, fill, label, or progress changes.
- Commit only when release occurs inside the valid control or target zone.
- Cancel when the pointer leaves the zone or the gesture is interrupted; restore the prior state without side effect.
- Never use this pattern for a normal low-risk navigation button merely to add animation.
- Fallback: the same action remains available through an ordinary tap control.

## 3. Scoped content transition

**Use for:** changing one region such as a period selector, metric, filter result, or title without implying a route change.

- Keep the shared shell stable.
- Transition only the content whose meaning changes; preserve context labels and selected controls.
- Avoid animating unrelated cards, navigation, or the entire screen.
- Acceptance: the person can identify both the selected control and the changed region throughout the transition.

## 4. Gesture direction lock

**Use for:** surfaces that combine horizontal and vertical gestures, such as galleries inside scrolling pages.

- Gather a small initial movement sample, then lock to the axis whose travel is clearly dominant.
- Once locked, keep the other axis stable for that gesture.
- Do not change the lock halfway through the same gesture.
- Fallback: visible next/previous controls and vertical scrolling remain functional.

## 5. Interruptible motion

**Use for:** cards, sheets, or carousels where a new touch should take control during an in-flight transition.

- A fresh gesture samples the visible position, stops the running animation, and continues from that exact position.
- Preserve velocity only when it makes the result feel continuous; never jump to an assumed start or end state.
- Release resolves to a named stable state using the normal commit threshold.
- Acceptance: rapid repeated swipes do not cause a snap, duplicate action, or inaccessible intermediate state.

## 6. Scrub preview

**Use for:** choosing a time, location, item sequence, image group, or other ordered value where preview reduces wrong commits.

- During drag, show the current candidate in place or in a lightweight preview.
- Commit the selected candidate on release only when the value is valid.
- Make the active position visible and keep adjacent candidates legible enough to compare.
- Fallback: step controls, a list, or a direct selector that can reach the same values.

## 7. Boundary resistance

**Use for:** a draggable or scrollable surface with finite limits.

- Beyond a real boundary, reduce movement relative to pointer travel instead of extending content indefinitely.
- Release returns the surface to the nearest valid edge with a short, calm settle.
- Do not use resistance to conceal unavailable content, a loading failure, or an invalid input error.
- Acceptance: the boundary is felt before release and the settled value is always valid.

## 8. Radial theme transition ｜圆形主题切换

**Use for:** switching between complete visual themes while making the initiating control feel causally connected to the change.

- Start at the actual click or touch position.
- Reveal the new theme with a circular clip whose radius reaches the farthest viewport corner.
- Keep both page layers at the same position and scale; only the upper layer is clipped.
- Fallback: a short non-spatial crossfade for reduced motion.
- Copyable prompt: `Implement a radial theme transition for an app interface. When the user presses the theme toggle, reveal the new theme from the exact point or touch position as the center of an expanding circle. Calculate the circle radius from the touch point to the farthest viewport corner. Keep both page layers at the same scale and position, and clip only the top layer with a circular mask. Support mouse and touch input, respect prefers-reduced-motion, and use a simple fallback transition when needed.`

## 9. Drag-to-reorder ｜拖拽排序

**Use for:** changing the order of items where position itself is meaningful.

- Lift the dragged item from normal flow and keep it attached to the pointer.
- Continuously calculate its insertion index and expose a clear empty slot.
- Let each surrounding item independently animate to its new position.
- Stop at the exact intermediate layout when the drag pauses; commit order only on release.
- Fallback: keyboard move controls and accessible reorder actions.
- Copyable prompt: `Create a draggable sortable list. When the user holds and drags one row, temporarily remove it from the normal list flow and calculate the insertion index continuously from the pointer position. The other rows should create a visible empty slot and move out of the way. Animate each row independently with a spring motion. Keep the dragged item attached to the pointer, prevent layout jumps, and support touch and keyboard interactions.`

## 10. Staggered bulk selection ｜批量勾选

**Use for:** making a batch selection legible without delaying the underlying action.

- Update the actual selection state immediately.
- Reveal checkmarks in sequence with a brief stagger and a subtle elastic scale.
- Keep later user actions available while the visual sequence runs.
- Fallback: screen readers receive the completed selection state immediately.
- Copyable prompt: `Implement a select-all interaction for a list of items. Update the selection state immediately but animate the checkmarks one by one with a short staggered delay from first item to last. Add a subtle elastic scale effect when each checkmark appears, then return each item to its normal size. Keep the sequence deliberate without slowing the actual state update, and support keyboard and screen-reader accessibility.`

## 11. Velocity-based slider snap ｜滑杆惯性吸附

**Use for:** selecting an ordered, stepped value where release velocity can make the control feel physical.

- Track drag velocity and let the thumb travel only a small extra distance after release.
- Spring to the nearest valid tick and clamp the terminal value to the allowed range.
- Keep the semantic value accurate throughout; overshoot is visual motion, not an invalid committed value.
- Fallback: keyboard step increments and a direct numeric alternative where needed.
- Copyable prompt: `Create a stepped slider for selecting a target value. Track pointer velocity while the user drags. On release, let the thumb continue slightly based on release velocity, then use a spring animation to settle at the nearest valid tick. Clamp the final value to the available range, make overshoot subtle, and support mouse, touch, keyboard control, and reduced-motion preferences.`

## 12. Animated text disclosure ｜文本展开

**Use for:** expanding help text, detail copy, or descriptions while preserving reading context.

- Measure the actual content height and animate from the current height to that measured target.
- Rotate the chevron or state icon with the disclosure.
- Keep reading order and screen-reader availability correct for collapsed and expanded states.
- Avoid sudden text insertion or a layout jump.
- Copyable prompt: `Create an animated text disclosure component for a collapsible description. Measure the real content height and animate the container from its current height to the measured height when opening, then back to the collapsed height when closing. Rotate the trailing chevron by 180 degrees, keep the content accessible to screen readers, and avoid layout jumps.`

## 13. Spring stepper progress ｜步骤条回弹

**Use for:** confirming completion of a form, purchase, or setup step without delaying progression.

- The next progress segment moves slightly beyond its target, then settles with a soft spring.
- Completed, current, and upcoming states remain distinct throughout.
- The real step value changes independently of the decorative overshoot.
- Fallback: reduced-motion uses an immediate state update.
- Copyable prompt: `Create a multi-step progress indicator. When the user completes a step, animate the next progress segment so it slightly overshoots its target and then settles with a soft spring. Keep completed, current, and upcoming states clear, keep the progress value accurate throughout, and do not delay navigation. Support keyboard accessibility and prefers-reduced-motion.`

## 14. Ripple feedback for related switches ｜开关联动反馈

**Use for:** showing relationship among nearby settings without changing their values.

- The source switch updates normally.
- Neighboring switches receive contained visual feedback, such as a small translation or ripple.
- Related controls never inherit the source switch's on/off state.
- Fallback: a group label or description communicates the relationship without motion.
- Copyable prompt: `Create a settings group with multiple toggle switches. When the user changes one switch, trigger subtle ripple-like feedback that spreads to neighboring switches. Neighboring switches may slightly shake or translate, but their actual on and off states must not change. Keep the effect inside the group, support touch and keyboard input, and disable motion for reduced-motion users.`

## 15. Curved card deletion ｜卡片曲线删除

**Use for:** deleting a card or row when its motion should clearly indicate its destination.

- The swipe must cross a visible threshold before deletion commits.
- After commitment, move the card along a curved path toward the delete affordance while reducing scale, rotating slightly, and fading.
- Remove from the data source only after the exit animation ends.
- Return cleanly to the original position when released below threshold.
- Fallback: keyboard delete control and confirmation behavior where the product requires it.
- Copyable prompt: `Create a swipe-to-delete card interaction. When a user swipes a card past the delete threshold, animate it along a curved path toward the delete icon or trash area while gradually reducing scale, rotating slightly, and fading opacity. Remove it from the data source after the exit animation completes. If released before the threshold, smoothly return it to its original position. Support touch, mouse, keyboard deletion, and reduced-motion preferences.`

## 16. Stacked card scroll ｜卡片堆叠滚动

**Use for:** ordered cards or history where users benefit from retaining the spatial trace of earlier items.

- Pin the leading card briefly at the boundary as following cards advance.
- Compute each compressed card's offset, scale, and layer depth from its relative position.
- Retain enough visible content to preserve scroll context; never discard cards abruptly.
- Fallback: ordinary sequential scrolling remains fully usable.
- Copyable prompt: `Create a vertically scrollable card stack. When the top card reaches the top boundary, keep it pinned briefly while following cards move upward and compress into a visible stack. Calculate each card’s vertical offset, scale, and depth from its relative position. Preserve scroll context, avoid abrupt disappearance, and support touch, mouse wheel, keyboard scrolling, and reduced-motion preferences.`

## 17. Expanding tag selection ｜标签挤开

**Use for:** selecting a tag, filter, or category where the selected option needs stronger emphasis within an existing row.

- Slightly enlarge the selected tag and animate neighbors aside without overlap.
- Preserve tag order and adapt the reflow when narrow widths require wrapping.
- Make the selected state clear before and after the layout movement.
- Fallback: keyboard navigation and a static selected treatment.
- Copyable prompt: `Create a selectable tag list with animated layout reflow. When the user selects a tag, slightly enlarge the active tag and make neighboring tags move aside to create enough space. Surrounding tags should smoothly translate rather than overlap or jump. Clearly show the selected state, preserve original order, handle wrapping on smaller screens, and support mouse, touch, keyboard navigation, and reduced-motion preferences.`
