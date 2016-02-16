[b]Types of Templates:[/b]
ATTACK
BIOME
CASTE
EXTRACT
INTERACTION
MATERIAL
TYPE
SUBTYPE
HEAD
TORSO
LEG
ARM
HAND
FOOT
EYE
EAR
NOSE
MOUTH
ORGANS
SKELETAL
ATTACHMENT_HEAD
ATTACHMENT_TORSO
ATTACHMENT_LIMBS
ATTACHMENT_MISC

[b]Example Template:[/b]
[TEMPLATE:-type-:-ID-]
 {DESCRIPTION:-desc-}
 {NAME:-names-}
 {ATTACKS:-attacks-}
 {ARGS:-args-}
 {TOKENS:-tokens-}
 {LINK:-tokens-}
 {EXCEPT:-tokens-}
 {PERCENT:-tokens-}
 {BODY:-body parts-}
 -raws-

Each template can have as many or as few of the above entries.

-type- is one of the above types
-ID- is the designation you give the template, must be unique
-desc- is a string which may be used in the creatures description (more below)
-names- complex behavior, see below
-attacks- is a list of attacks that is associated with the template, all attacks associated with templates will be added to the creature (seperated by commas)
-tokens- a list of self declared tokens which are added to the creature (more below)
-body parts- a list of body parts which are added to the [BODY:--] token of the creature
-raws- any additional raws that are added to the creature, the additions are done in a specific order (more below)

[b]TOKENS vs. LINK vs. EXCEPT vs. PERCENT[/b]
-tokens- specified in {TOKENS} are added to the creature when the template is selected
-tokens- specified in {LINK} are checked against when a template is considered, if the LINK tokens are present the template is selected, if not the template is passed
-tokens- specified in {EXCEPT} work exactly the opposite of {LINK}, if present the template is passed, if not the template is selected
-tokens- specified in {PERCENT} are assigned at the onset of creature creation depending on values that the user defines in the creature creation GUI

Note that there are specific special tokens used internally, these tokens are precedded with an '#' and are;
#VERMIN - Checks if the creature is the correct size for vermin (defined by Size: Vermin)
#TINY - Checks if the creature is the correct size for tiny vermin (defined by Size: Tiny)
#TRADER - Checks if the creature is the correct size for a trading animal (defined by Size: Trade)
#MALE - Used for defining male castes in TEMPLATE:CASTE - LINK
#FEMALE - Used for defining female castes in TEMPLATE:CASTE - LINK
#DESC - Used to fill in the creature description when creating raws, very little use for this as the script currently creates a description for each caste already
#NAME - Used to fill the the creatue name when creating raws, very useful, allows for naming of things directly in the templates
#ARG1, #ARG2, #ARG3, etc... - Used to fill in the arguments provided in TEMPLATE - ARGS
#SWIMMING_GAITS - If this tag is present in a creature (no matter which template the creature recieved it from) will alter the gaits, flipping the WALK and SWIM gaits
#ONLY_SWIMMING - Same effect as above, but removes all other gaits (WALK, CLIMB, CRAWL, FLY) 
#FLYING_GAITS - If this tag is present in a creature (no matter which template the creature recieved it from) will alter the gaits, moving WALK to FLY and CRAWL to WALK
#ONLY_FLYING - Same effect as above, but removes all other gaits (WALK, CLIMB, CRAWL, SWIM)
#NOARMS - Removes the CLIMB gait
#NOLEGS - Removes the WALK gait

[b]Creation Process:[/b]
Step 1: Generate all numbers based on user input. This includes argument numbers, size, age, population numbers, attributes, and any other number based entries.
Step 2: Calculate {PERCENT} tokens based on random number generation (e.g. if randint(1,100) < PERCENT add -tokens-)
Step 3: Select the TYPE template to be used for the creature. This is the first template to be selected
Step 4: Select the BIOME template
Step 5: Begin selecting body templates.
 Start by selecting 1 TORSO, 1 HEAD, 1 LEG, 1 ARM, 1 HAND, and 1 FOOT template
 Then select 1 ORGANS and 1 SKELETAL template
 Next select 1 EYE, 1 EAR, 1 MOUTH, and 1 NOSE template
 Finally select a number of ATTACHMENT_TORSO, ATTACHMENT_HEAD, ATTACHMENT_LIMBS, and ATTACHMENT_MISC templates based on a user defined limit
 Note that each of these templates is checked against the {LINK} and {EXCEPT} and the -tokens- of the creature. The order is specific, so a   HEAD template can not forbid a TORSO template, but a TORSO template can forbid a HEAD template
Step 6: Select the MATERIAL template
Step 7: Select the CASTE templates, by default a single template with {LINK:#MALE} and a single template with {LINK:#FEMALE} will be selected. This is configurable by changing the number of female, male and neutral castes in the GUI
Step 8: Select the SUBTYPE templates. The number of SUBTYPE templates chosen is between 0 and Max Subtypes which is configurable in the GUI
Step 9: Select and EXTRACT templates. These templates are chosen differently than others. Instead of randomly picking one, all templates that meet the {LINK} and {EXCEPT} criteria are added to the creature
Step 10: Select the INTERACTION templates. In the gui the maximum number of interactions a single creature can have is specifiable. In addition you can specify the percent chance that each individual INTERACTION template has for being added.
Step 11: Get all of the {ATTACKS} from each template that has been selected for the creature
Step 12: Now all of the templates have been selected, the actual creation of the creature begins. The format of the creation is (entries with an '#' are generated as described below)

[CREATURE:--]
 [NAME:#NAME]
 [CREATURE_TILE:--]
 [COLOR:--:--:--]

=> TYPE template -raws- go here

=> SUBTYPE templates -raws- go here

=> BIOME template -raws- go here

=> all numbers generated in Step 1: go here (e.g. [MAX_AGE:--:--], [BODY_SIZE:--:--:--], [CHILD:--], etc...)

 [APPLY_CREATURE_VARIATION:#SPEED]

 [BODY:#BODY]

=> MATERIAL template -raws- go here

=> EXTRACT templates -raws- go here

=> INTERACTION templates -raws- go here

=> ATTACK templates -raws- go here

=> CASTE template -raws- go here, additionally [DESCRIPTION:#DESC] and [CASTE_NAME:#CASTE_NAME] are added here as well

#DESC is generated by using the various -desc- provided in the templates. The actual method for how they are added is
 body_dc = torso_dc + ' ' + torsoa_dc + ', ' + head_dc + ' ' + heada_dc
 limb_dc = arm_dc + ' ' + hand_dc + ' and ' + leg_dc + ' ' + foot_dc
 face_dc = eye_dc + ', ' + nose_dc + ', ' + mouth_dc + ', and ' + ear_dc
 description = type_dc + subtype_dc + '. ' + material_dc + ' with ' + body_dc + ' and ' + face_dc + '. It has ' + limb_dc + '. It ' + biome_dc + '. ' + extract_dc + '. ' + interaction_dc
Note that, while not perfect, it does generate reasonable descriptions, for example;
"A ferocious animal found only in the most savage of landscapes. A scaled creature with a four part body, three heads and eight eyes, a large trunk, no visible mouth, and one ear. It has four upper tentacles with claws and four legs and feet with four toes each. It Is only found underground."

#BODY is generated by combining the {BODY} -body parts- from each template. They are added together TORSO -> HEAD,ARM,LEG -> HAND,FOOT,EYE,EAR,NOSE,MOUTH -> ORGANS,SKELETAL -> all others

#SPEED is calculated for each GAIT (WALK, CLIMB, CRAWL, SWIM, and FLY) based on the numbers provided in the GUI. The speeds are then altered depending on the special tokens present on the creature. This allows for you to generate land and water animals in the same group by switching the WALK/SWIM gaits depending on which they are.

#NAME and #CASTE_NAME are generated in one of two ways. Either randomly by a chosen DF language file. Or based on the templates {NAME}. Currently the {NAME} feature is bugged, but I am hoping to have it working soon.