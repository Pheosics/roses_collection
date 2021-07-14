Note that any file that begins with templates_ will be read in and processed.

Types of Templates:
			ATTACK - All templates are able to add attacks, those attacks are stored here for easy reference
			BIOME - Gives the creatures the [BIOME:<biome>] creature tokens
			CASTE - Used for selecting male and female (and neutral) castes for the creature
			EXTRACT - Provides a creature with an extract (e.g. poison, venom, honey, etc...)
			INTERACTION - Gives the creature an interaction (e.g. cleans itself, hides, spits web, etc...)
			MATERIAL - Give the creature it's base materials and sets the tissue layers
			TYPE - Assigns the basic type, currently MUNDANE, SAVAGE, EVIL, and GOOD, but can be anything desired
			SUBTYPE - These templates provide the creature with special traits (e.g. FLIER, AMPHIBIOUS, SHEARABLE, etc...)
			HEAD - Picks the head body part to assign to the creature, can also include neck and throat
			TORSO - Picks the upper and lower body part to assign to the creature
			LEG - Picks the body parts to attach to the lower body (in standard creatures, legs)
			ARM - Picks the body parts to attach to the upper body (in standard creatures, arms)
			HAND - Picks the body parts to attach to the ARM template (in standard creatures, hands)
			FOOT - Picks the body parts to attach to the LEG template (in standard creatures, feet)
			EYE - Picks the eye(s) to attach to the HEAD template
			EAR - Picks the ear(s) to attach to the HEAD template
			NOSE - Picks the nose(s) to attach to the HEAD template
			MOUTH - Picks the mouth(s) to attach to the HEAD template
			TONGUE - Picks the tongue(s) to attach to the HEAD template
			TEETH - Picks the teeth to attach to the HEAD template
			ORGANS - Picks the set of organs to include
			SKELETAL - Picks the set of ribs, skull, and other special bones
			ATTACHMENT_HEAD - Templates for special body parts that attach to the HEAD template (horns, tusks, mandibles, etc...)
			ATTACHMENT_TORSO - Templates for special body parts that attach to the TORSO template (wings, tails, fins, etc...)
			ATTACHMENT_LIMBS - Templates for special body parts that attach to the ARM and LEG templates (fins, spikes, etc...)
			ATTACHMENT_MISC - Templates for special body parts that attach to any/multiple templates (spikes, fins, etc...)

Example Template:
	All of the above templates will take the exact same list of inputs. The full list is as follows;
	[TEMPLATE:-type-:-ID-]
Basic Inputs
 		{DESCRIPTION:-desc-}
 		{NAME:-names-}
 		{ATTACKS:-attacks-}
 		{TOKENS:-tokens-}
 		{LINK:-tokens-}
 		{EXCEPT:-tokens-}
 		{PERCENT:-tokens-}
		{TEMPLATES:-templates-}
		{WEIGHT:-weight-}
		{BP_COLORS:-body part category-}
 		{BODY:-body parts-}
Complex Inputs
 		{ARGS:-args-}
		{REPLACEMENTS:-replace-}
		{ITERATIONS:-iterate-}

 			-raws-

	Each template can have as many or as few of the above entries as desired. Multiples in a single input are seperated by commas.
	Raws should be included at the end of each template. The order of other inputs is not important

Basic Input Details:
	The following describes in detail what each input does;
	{DESCRIPTION:-desc-}
		Tells the code what to include (if anything) in the creature's description. There are no special tokens associated with this input.
                The exact format for creating the creature description is discussed below.
			EXAMPLE:
				{DESCRIPTION:two heads}

	{NAME:-names-}
		Is used in forming the creature's name, the special tokens associated with this input are ADJ, PREFIX, MAIN, SUFFIX
			ADJ - Gives an adjective that can be used in the creatures name
			PREFIX - Gives a prefix that can be affixed to the MAIN name
			MAIN - Give a word that can be used as the creatures base name
			SUFFIX - Gives a suffix that can be appended to the MAIN name
		The exact format for creating the creature name is discussed below.
			EXAMPLE:
				{NAME:ADJ:one eyed,MAIN:cyclops}

	{ATTACKS:-attacks-}
		The list of attacks that a specific template should add to a creature. All attacks from each template are added.
			EXAMPLE:
				{ATTACKS:ATTACK_PUNCH}

	{TEMPLATES:-templates-}
		A list of templates that are to be included (and therefore skipped).
		Exact usage of this input will be discussed in the ordering section below.
			EXAMPLE:
				{TEMPLATES:HEAD,ARM,LEG,HAND,FOOT}

	{WEIGHT:-weight-}
		The numerical weight to assign the template. When templates are chosen, they are chosen randomly based on their weights.
		Default weight (if the input is not included) is 100. All weights are relative.
			EXAMPLE:
				{WEIGHT:50}

	{TOKENS:-tokens-}
		A list of tokens that are added to the creature if the template is chosen.
		Most tokens are user-defined, but there are a handful of built in tokens that will be discussed below. All built in tokens begin with #
			EXAMPLE:
				{TOKENS:SHEARABLE,TRADE_ANIMAL}

	{LINK:-tokens-}
		A list of tokens that the creature must have from previous templates in order to be chosen.
		This is discussed in more detail in the ordering section.
			EXAMPLE:
				{LINK:WATER_ONLY,AQUATIC}

	{EXCEPT:-tokens-}
		A list of tokens that forbid a template from being chosen if the creature has.
		This is discussed in more detail in the ordering section.
			EXAMPLE:
				{EXCEPT:WATER_ONLY}

	{PERCENT:-tokens-}
		A list of tokens that are chosen from a probability given at run time.
		Each token present in each PERCENT input in each template is given as a list on the gui. These tokens are assigned before anything else.
		This is discussed in more detail in the ordering section.
			EXAMPLE:
				{PERCENT:VENOM}

	{BP_COLORS:-body part category-}
		This input tells the code to generate a color for the specific body part category.
		Colors and color definitions are discussed in detail below.
			EXAMPLE:
				{BP_COLORS:SKIN,HAIR}

	{BODY:-body parts-}
		A list of body parts that should be added to the creatures [BODY:--].
		The order the body parts are added is the same as the order the templates are read. Discussed in the ordering section below.
			EXAMPLE:
				{BODY:TORSO_1PART,HEAD}

Complex Input Details:
	{ARGS:-args-}
		A complex input, it is used to vary templates across creatures without needing multiple templates.
		It allows for things such as varying strength of poisons, clutch sizes, pop ratios, etc... all using the same template.
		Each argument in each ARGS input in each template is given a Min/Max entry on the gui.
			EXAMPLE:
			[TEMPLATE:EXAMPLE_ARGS]
				{ARGS:CLUTCH_MIN,CLUTCH_MAX}
					[CLUTCH_SIZE:#ARG1:#ARG2]

		If a creature were to get assigned this template then it would choose a value for the arguments and place them in the cooresponding slots.
		This allows two creatures with the same template to have different numbers.

	{REPLACEMENTS:-replace-}
		This input will create multiple templates out of a single template. Any #REPLACE flags will get replaced with the declared variables
		There must be the same number of variables (seperated by ,) as the number of #REPLACE flags (e.g. if you have a #REPLACE1 and #REPLACE2 you need two variables)
		Each replacement you wish to make will be seperated by :, so for example
			EXAMPLE:
			[TEMPLATE:EXAMPLE_REPLACEMENTS_#REPLACE2]
				{REPLACEMENTS:HOOF:PAW:STUMP,1:2:3}
					[BODYGLOSS:#REPLACE1]

		If this template were read in it would be read in as 3 seperate templates, namely;
			[TEMPLATE:EXAMPLE_REPLACEMENTS_1]
				[BODYGLOSS:HOOF]

			[TEMPLATE:EXAMPLE_REPLACEMENTS_2]
				[BODYGLOSS:PAW]

			[TEMPLATE:EXAMPLE_REPLACEMENTS_3]
				[BODYGLOSS:STUMP]

		This allows you to create many many templates without cluttering up your template files.

	{ITERATIONS:-iterate-}
		This functions the exact same as REPLACEMENTS except it uses #ITERATE and is done AFTER the replacements are run.
		This means that if you had a single template with 3 replacements and 3 iterations you would get 9 total templates.
		Expanding on our above example
			[TEMPLATE:EXAMPLE_ITERATIONS_#ITERATE1_#REPLACE1]
				{REPLACEMENTS:HOOF:PAW:STUMP}
				{ITERATIONS:SMALL:LARGE:GIANT,5:50:500}
					[BODYGLOSS:#REPLACE1]
					[RELSIZE:BY_CATEGORY:HAND:#ITERATE2]
		This will give you
			[TEMPLATE:EXAMPLE_ITERATIONS_SMALL_HOOF]
				[BODYGLOSS:HOOF]
				[RELSIZE:BY_CATEGORY:HAND:5]

			[TEMPLATE:EXAMPLE_ITERATIONS_SMALL_PAW]
				[BODYGLOSS:PAW]
				[RELSIZE:BY_CATEGORY:HAND:5]

			[TEMPLATE:EXAMPLE_ITERATIONS_SMALL_STUMP]
				[BODYGLOSS:STUMP]
				[RELSIZE:BY_CATEGORY:HAND:5]

			[TEMPLATE:EXAMPLE_ITERATIONS_LARGE_HOOF]
				[BODYGLOSS:HOOF]
				[RELSIZE:BY_CATEGORY:HAND:50]

			[TEMPLATE:EXAMPLE_ITERATIONS_LARGE_PAW]
				[BODYGLOSS:PAW]
				[RELSIZE:BY_CATEGORY:HAND:50]

			[TEMPLATE:EXAMPLE_ITERATIONS_LARGE_STUMP]
				[BODYGLOSS:STUMP]
				[RELSIZE:BY_CATEGORY:HAND:50]

			[TEMPLATE:EXAMPLE_ITERATIONS_GIANT_HOOF]
				[BODYGLOSS:HOOF]
				[RELSIZE:BY_CATEGORY:HAND:500]

			[TEMPLATE:EXAMPLE_ITERATIONS_GIANT_PAW]
				[BODYGLOSS:PAW]
				[RELSIZE:BY_CATEGORY:HAND:500]

			[TEMPLATE:EXAMPLE_ITERATIONS_GIANT_STUMP]
				[BODYGLOSS:STUMP]
				[RELSIZE:BY_CATEGORY:HAND:500]

		The templates provided have several examples of all three of these complex inputs.

	-raws-
		All your raws (besides those in ATTACKS and BODY inputs} will go here. This input has three special tokens
			#NAME - places the creature name here, useful for naming milk, honey, etc...
			#DESC - places the creature description here, useful if you want a different MALE/FEMALE description
			#ARG<#> - Replaces the specific argument with a value determined from the Min/Max from the gui
		All three of these tokens, and the process for actually generating the raws are discussed below.

Built-In Tokens:
	Note that there are specific special tokens used internally, these tokens are precedded with an '#' and are;
		#VERMIN - Checks if the creature is the correct size for vermin (defined by Size: Vermin)
		#TINY - Checks if the creature is the correct size for tiny vermin (defined by Size: Tiny)
		#TRADER - Checks if the creature is the correct size for a trading animal (defined by Size: Trade)
		#MALE - Used for defining male castes in TEMPLATE:CASTE - LINK
		#FEMALE - Used for defining female castes in TEMPLATE:CASTE - LINK
		#DESC - Used to fill in the creature description when creating raws
		#NAME - Used to fill the the creatue name when creating raws, very useful, allows for naming of things directly in the templates
		#ARG1, #ARG2, #ARG3, etc... - Used to fill in the arguments provided in TEMPLATE - ARGS
		#SWIMMING_GAITS - If this tag is present in a creature it  will alter the gaits, flipping the WALK and SWIM gaits
		#ONLY_SWIMMING - Same effect as above, but removes all other gaits (WALK, CLIMB, CRAWL, FLY)
		#FLYING_GAITS - If this tag is present in a creature it  will alter the gaits, moving WALK to FLY and CRAWL to WALK
		#ONLY_FLYING - Same effect as above, but removes all other gaits (WALK, CLIMB, CRAWL, SWIM)
		#NOARMS - Removes the CLIMB gait
		#NOLEGS - Removes the WALK gait

Ordering:
	The order the templates are read and the creature is created is possibly the most important part of the system.
	Since you can have a template LINK or EXCEPT a token understanding the order is crucial to creating functional creatures.
	The order is as follows, and is repeated for each creature created (details will follow)
		1. Generate all numbers based on the gui input. This includes ARG numbers, size, age, population, attributes, etc...
		2. Calculate PERCENT tokens
		3. Begin TEMPLATE selection
			a. Select the TYPE template
			b. Select the BIOME template
			c. Select the MATERIAL template
			d. Begin body creation
				01. Select the TORSO template
				02. Select the HEAD template
				03. Select the LEG template
				04. Select the ARM template
				05. Select the HAND template
				06. Select the FOOT template
				07. Select the EAR template
				08. Select the EYE template
				09. Select the MOUTH template
				10. Select the NOSE template
				11, Select the TONGUE template
				12. Select the TOOTH template
				13. Select the ORGANS template
				14. Select the SKELETAL template
				15. Select the ATTACHMENT_HEAD template
				16. Select the ATTACHMENT_TORSO template
				17. Select the ATTACHMENT_LIMB template
				18. Select the ATTACHMENT_MISC template
			e. Select the CASTE template(s)
			f. Select the SUBTYPE template(s)
			g. Select the EXTRACT template(s)
			h. Select the INTERACTION template(s)
		4. Create creature description
		5. Populate BP_COLORS and ATTACKS
		6. Create creature name
		7. Create creature raws
		8. Write creature raws to file
		9. Repeat

	What this heirarchy means is a TORSO template could add a <token> to a creature that requires/forbides a specific HEAD template,
	but a HEAD template can not require/forbid a specific TORSO template. The exception to this is the PERCENT tokens. If a HEAD template
	has a PERCENT input those percents are calculated at the very start. Typically these tokens are used to LINK the same template (so that
	a single template will have {PERCENT:X} and {LINK:X}) but it doesn't have to.

	A detailed walkthrough of this process;
		1. There are several numbers that are generated for each creature, each one requires some user input and follows a specific rule
			a. Sizes - Inputs: Mean, Sigma, Min, Vermin, Tiny, Trade
			     	Size tokens [BODY_SIZE:x_1:y_1:a_1], [BODY_SIZE:x_2:y_2:a_2], and [BODY_SIZE:x_3:y_3:a_3] are calculated as follows:
				 a_3 is calculated by selecting a random number from a gaussian distribution with a mean Mean and sigma Sigma
				 a_1 is calculated by selecting a random number from a gaussian distribution with a mean a_3/100 and sigma Sigma/100
				 a_2 = a_1 + a_3*75%, if this is > a_3 then a_2 and a_3 are switched
				 x_1, y_1, y_2, and y_3 are all set to 0 for now
				 x_2 is taken from [BABY:n] (see Ages for calculation) such that x_2 = n + 1
				 x_3 is taken from [CHILD:n] (see Ages for calculation) such that x_3 = n + 2
			     	Min is the minimum size of any creature, if a_3 < Min then a_3 = Min
			     	Vermin sets the maximum size needed for the #VERMIN flag, below this size #VERMIN is set to True
			     	Tiny sets the maximum size needed for the #TINY flag, below this size #TINY is set to True
			     	Trade sets the minimum size needed for the #TRADE flag, above this size #TRADE is set to True
			b. Ages - Inputs: Max, Min, Baby, Child, Delta
			     	Ages tokens [MAX_AGE:a:b], [BABY:c], [CHILD:d] are calculated as follows:
				 a is chosen between Min and Max
				 b is chosen between Max and Max + Delta
				 c is chosen between Baby - Delta and Baby + Delta
				 d is chosen between Child - Delta and Child + Delta
			     	all choices are selected randomly from a triangular distribution
			     	if c > d then c is set to 0 and d is set to c
			     	if either c or d is 0 then that tag will not be added to the creature
			c. Population Numbers - Inputs: Max, Min
			     	Population token [POPULATION_NUMBER:x:y] is calculated as follows:
				 x is chosen between 1 and Min
				 y is chosen between Min and Max
			     	choices are selected randomly from a triangular distribution
			     	for Vermin and Tiny creatures x = 250 and y = 500
			d. Cluster Numbers - Inputs: Max, Min
			     	Cluster token [CLUSTER_NUMBER:x:y] is calculated as follows:
				 x is chosen between 1 and Min
				 y is chosen between Min and Max
			     	choices are selected randomly from a triangular distribution
			     	for Vermin and Tiny creatures the cluster token is not used
			e. Interactions - Inputs: Max, Chance
				Max is the maximum number of interactions and one creature can have
				Chance is the percent chance that each interaction slot is filled
				For example, if Max is 3 and Chance is 50 then slot 1 will have a 50% chance of being filled,
				slot 2 will have a 50% chance of being filled, and slot 3 will have a 50% chance of being filled
				This, of course, is dependent on their being 3 interactions that the creature meets the criteria for
			f. Castes - Inputs: Male, Female, Neutral
			     	The maximum number of castes each creature can have which meets specific criteria
				Male sets the maximum number of castes with the #MALE LINK
				Female sets the maximum number of castes with the #FEMALE LINK
				Neutral sets the maximum number of castes without the #MALE or #FEMALE LINK
			g. Subtypes - Input: Max
			     	Number of subtype templates one creature can have, their total number of subtypes will be chosen randomly between 0 and Max
			h. Argument Values - Inputs: Max, Min
				All arguments found in the Templates
				When each creature is generated a value is chosen for each argument
				The value is selected from a triangular distribution between Min and Max
			i. Gait Speeds - Inputs: Max, Min
			     	Speed of various gaits in kph. Chosen from a triangular distribution between Min and Max
			j. Attribute Values - Inputs: Max, Min, Sigma
			     	Attribute tokens [<>_ATT_RANGE:<>:a:b:c:d:e:f:g] are calculated as follows:
				 a is taken from a gaussian distribution with mean Min and sigma Sigma
				 g is taken from a gaussian distribution with mean Max and sigma Sigma
				 d = (a+g)/2
				 c/e = d -/+ 2*(g-d)/10
				 b/f = d -/+ 5*(g-d)/10
			     	If Max is 0 then the attribute token is not added to the creature

		2. PERCENT tokens are also generated from gui input. They are placed on the front panel with only a single input
			Percentage chance given token will be true
			If you wish to generate a set of creatures that all share a commonality you would set the percent to 100

		3. TEMPLATES are chosen randomly with predefined weightings. Each template can be toggled on/off in the gui (default all on)
			First the creature is checked to make sure it doesn't already have the specific TEMPLATE from a TEMPLATES input
			If it does not a list of eligible templates is selected
			For a template to be selected it first must satisfy any LINK and EXCEPT inputs present.
			The list of eligible templates is then selected from randomly
			The TOKENS and TEMPLATES from the picked template are then added to the creature and the process continues with the next template
			
		4. The creature description is created as outlined below
		5. Colors are chosen as outlined below, all ATTACKS from all templates are added to the creature
		6. The creature name is created as outlined below
		7. All the information is then collected together into raw format as outlined below
		8. The creature is written to a creature file with [CREATURE:RC_<#>] as the identifying tag
		9. This process repeats for as many creatures as you specifed to create in the gui

Description Generation:
        The creature description is carefully created to provide as humanly readable a description as possible.
        The full description forumla (assuming each template was chosen and each template has a DESCRIPTION input) is as follows;

                'A(n) ' + TYPE + ', it is found in ' + BIOME + '. It is active ' + ACTIVE + '.' +
                'It ' + SUBTYPE_1 + ', ' + SUBTYPE_2 + ', and ' + SUBTYPE_3 + '. It has ' + TORSO + ' and is ' + MATERIAL + '.' +
                'It has ' + HEAD + ' with ' + EYE + ', ' + EAR + ', ' + NOSE + ', and ' + MOUTH + ' with ' + TONGUE + ' and ' + TOOTH + '.' +
                'It has ' + ARM + ' with ' + HAND + ' and ' + LEG + ' with ' + FOOT + '.' +
                'It has ' + ATTACHMENT_HEAD + ', ' + ATTACHMENT_TORSO + ', ' + ATTACHMENT_LIMB + ', and ' + ATTACHMENT_MISC + '.' +
                'It ' + EXTRACT + '. It ' + INTERACTION + '. Maximum Size: ' + SIZE + ' kg.

        As you can see it is not very pretty to look at formulaicly, but it generates a description like (formatted to match the layout above);
                A mundane animal, it is found in temperate forests. It is active at dawn.
                It has a large upper body and small lower body and is covered in fur with extremely thick skin.
                It has a single head on a long neck with no eyes, large ears, a snout, and a large muzzle with large fangs.
                It has no arms and four legs with hooves.
                It has a large crest on top of it's head and a small fin on it's legs.
                Maximum Size: 23kg.

        Notice that this particular creature doesn't have an extract or an interaction so those are not present (even the punctiuation and It).
        This is how it works for each description, if the template doesn't have one, nothing is added to the creature description.
        When this happens all of the interconnecting "with"s, "It has", and punctiuation is removed.
        Because of the way the description is formed, a certain format is expected for each templates description. Each example template follows this format.

Name Generation:
        Names are another complicated thing to create. The basics for creating a name are;
                1. Pick between 1 and 2 ADJ names
                2. Pick between 0 and 1 PREFIX names
                3. Pick 1 MAIN name
                4. Pick between 0 and 1 SUFFIX names
                5. The name is then constructed as ADJ_1 + ADJ_2 + PREFIX + '-' +  MAIN + '-' +  SUFFIX
        There are certain rules it takes into account when selecting a name;
                1. No single template can contribute more than one name part (if you have a [NAME:ADJ:arctic,ADJ:snow] you don't want a snow arctic --)
                2. All name parts are selected randomly, as such a combination may not be found on the first try. 1000 tries are performed.
                3. If, after 1000 tries, no name has been created. It will try to make a name (once) without following rule #1.
                4. If a name is still not generated the creature will be named "Random Creature <#>" for ease of identifying in the file.
        In addition to the included ADJ names, an ADJ name may be created referencing the color chosen for BP_COLORS, this is described below.

Color Generation:
        Each BP_COLORS input is given it's own color. These colors, their grouping, and their naming are found in rcc_globals.py
        They are copied below for convinience, but are fully modable.
        By default a single key from color_groups is chosen for each BP_COLOR inputs
        Then all the colors associated with that key are added to the TL_COLOR_MODIFIER.
        You can also tell the code to simply select a single entry from colors and use that for the TL_COLOR_MODIFIER (this is how eyes work with eye_colors)
        The ADJ discussed above is generated by combining color_names with part_names given you something like ADJ:crimson scaled
        The raws created for the BP_COLORS follow the format;

                [SET_TL_GROUP:BY_CATEGORY:ALL:<part>]
                        [TL_COLOR_MODIFIER:<key:entry>:1:<key:entry>:1]
                        [TLCM_NOUN:<part:noun>:SINGULAR/PLURAL]

        SINGULAR/PLURAL is currently just chosen depending on if the <part:noun> ends in an s or not
        The following are the currently defined colors, color_groups, color_names, part_nouns, part_names, eye_colors, and eye_color_names;

 colors = ['BLACK','CLEAR','GRAY','SILVER','WHITE','TAUPE_ROSE','CHESTNUT','MAROON','RED','VERMILION','RUSSET','SCARLET',
           'BURNT_UMBER','TAUPE_MEDIUM','DARK_CHESTNUT','BURNT_SIENNA','RUST','AUBURN','MAHOGANY','PUMPKIN','CHOCOLATE',
           'TAUPE_PALE','TAUPE_DARK','DARK_PEACH','COPPER','LIGHT_BROWN','BRONZE','PALE_BROWN','DARK_BROWN','SEPIA',
           'OCHRE','BROWN','CINNAMON','TAN','RAW_UMBER','ORANGE','PEACH','TAUPE_SANDY','GOLDENROD','AMBER','DARK_TAN',
           'SAFFRON','ECRU','GOLD','PEARL','BUFF','FLAX','BRASS','GOLDEN_YELLOW','LEMON','CREAM','BEIGE','OLIVE','YELLOW',
           'IVORY','LIME','YELLOW_GREEN','DARK_OLIVE','CHARTREUSE','FERN_GREEN','MOSS_GREEN','GREEN','MINT_GREEN',
           'ASH_GRAY','EMERALD','SEA_GREEN','SPRING_GREEN','DARK_GREEN','JADE','AQUAMARINE','PINE_GREEN','TURQUOISE',
           'PALE_BLUE','TEAL','AQUA','LIGHT_BLUE','CERULEAN','SKY_BLUE','CHARCOAL','SLATE_GRAY','MIDNIGHT_BLUE','AZURE',
           'COBALT','LAVENDER','DARK_BLUE','BLUE','PERIWINKLE','DARK_VIOLET','AMETHYST','DARK_INDIGO','VIOLET','INDIGO',
           'PURPLE','HELIOTROPE','LILAC','PLUM','TAUPE_PURPLE','TAUPE_GRAY','FUCHSIA','MAUVE','LAVENDER_BLUSH','DARK_PINK',
           'MAUVE_TAUPE','DARK_SCARLET','PUCE','CRIMSON','PINK','CARDINAL','CARMINE','PALE_PINK','PALE_CHESTNUT'
          ]
 color_groups = {'BLACK':['BLACK','CHARCOAL'],
                 'WHITE':['GRAY','SILVER','WHITE','IVORY','PEARL','ASH_GRAY'],
                 'RED':['TAUPE_ROSE','CHESTNUT','MAROON','RED','VERMILION','RUSSET','SCARLET'],
                 'BROWN':['PUMPKIN','CHOCOLATE','TAUPE_PALE','TAUPE_DARK','DARK_PEACH','COPPER','LIGHT_BROWN'],
                 'YELLOW':['SAFFRON','ECRU','GOLD','BUFF','FLAX','BRASS','GOLDEN_YELLOW','LEMON','CREAM','BEIGE','OLIVE','YELLOW'],
                 'GREEN':['LIME','YELLOW_GREEN','FERN_GREEN','MOSS_GREEN','GREEN','EMERALD','SEA_GREEN','DARK_GREEN','JADE','AQUAMARINE','PINE_GREEN'],
                 'BLUE':['TURQUOISE','PALE_BLUE','TEAL','AQUA','LIGHT_BLUE','CERULEAN','SKY_BLUE','MIDNIGHT_BLUE','AZURE','COBALT','DARK_BLUE','BLUE'],
                 'ORANGE':['ORANGE','TAUPE_SANDY','GOLDENROD','AMBER','DARK_TAN','SAFFRON'],
                 'PURPLE':['DARK_VIOLET','AMETHYST','DARK_INDIGO','VIOLET','INDIGO','PURPLE','HELIOTROPE','LILAC','PLUM','TAUPE_PURPLE'],
                 'PINK':['FUCHSIA','MAUVE','LAVENDER_BLUSH','DARK_PINK','DARK_SCARLET','CRIMSON','PINK','CARDINAL','CARMINE','PALE_PINK','PALE_CHESTNUT']
                 }
 color_names = {'BLACK':['black','charcoal'],
                'WHITE':['gray','silver','white','ivory'],
                'RED':['rose','maroon','red','scarlet'],
                'BROWN':['pale','light brown','copper','brown'],
                'YELLOW':['gold','brass','beige','yellow'],
                'GREEN':['green','emerald','jade'],
                'BLUE':['turquoise','teal','azure','cobalt','blue'],
                'ORANGE':['orange','sandy','amber'],
                'PURPLE':['violet','amethyst','purple'],
                'PINK':['crimson','pink','scarlet']
               }
 eye_colors = ['IRIS_EYE_AMETHYST','IRIS_EYE_AQUAMARINE','IRIS_EYE_BRASS','IRIS_EYE_BRONZE','IRIS_EYE_COBALT',
               'IRIS_EYE_COPPER','IRIS_EYE_EMERALD','IRIS_EYE_GOLD','IRIS_EYE_HELIOTROPE','IRIS_EYE_JADE',
               'IRIS_EYE_OCHRE','IRIS_EYE_RAW_UMBER','IRIS_EYE_RUST','IRIS_EYE_SILVER','IRIS_EYE_SLATE_GRAY',
               'IRIS_EYE_TURQUOISE'
              ]
 eye_color_names = {'IRIS_EYE_AMETHYST':'amethyst',
                    'IRIS_EYE_AQUAMARINE':'aquamarine',
                    'IRIS_EYE_BRASS':'brass',
                    'IRIS_EYE_BRONZE':'bronze',
                    'IRIS_EYE_COBALT':'cobalt',
                    'IRIS_EYE_COPPER':'copper',
                    'IRIS_EYE_EMERALD':'emerald',
                    'IRIS_EYE_GOLD':'golden',
                    'IRIS_EYE_HELIOTROPE':'purple',
                    'IRIS_EYE_JADE':'jade',
                    'IRIS_EYE_OCHRE':'brown',
                    'IRIS_EYE_RAW_UMBER':'brown',
                    'IRIS_EYE_RUST':'brown',
                    'IRIS_EYE_SILVER':'silver',
                    'IRIS_EYE_SLATE_GRAY':'gray',
                    'IRIS_EYE_TURQUOISE':'turquoise'
                   }
 part_nouns = {'SCALE':'scales',
               'CHITIN':'chitin',
               'SKIN':'skin',
               'HAIR':'haired',
               'FEATHER':'feathers',
               'HORN':'horn',
               'TUSK':'tusk',
               'CREST':'crest',
               'FRILL':'frill',
               'BEAK':'beak',
               'BILL':'bill',
               'EYE':'eyes'
              }
 part_names = {'SCALE':'scaled',
               'CHITIN':'chitinous',
               'SKIN':'skinned',
               'HAIR':'haired',
               'FEATHER':'feathered',
               'HORN':'horned',
               'TUSK':'tusked',
               'CREST':'crested',
               'FRILL':'frilled',
               'BEAK':'beaked',
               'BILL':'billed',
               'EYE':'eyed'
              }

Raw Creation:
	The creature raws are placed in the following order
		[CREATURE:RC_<#>]
			[NAME:#NAME]

			TYPE template -raws-
			
			SUBTYPE templates -raws-
			
			BIOME template -raws-
		
			All numbers generated in Step 1: (e.g. [MAX_AGE:--:--], [BODY_SIZE:--:--:--], [CHILD:--], etc...)
	
			[APPLY_CREATURE_VARIATION:#SPEED]

			[BODY:#BODY]

			MATERIAL template -raws-

			EXTRACT templates -raws-

			INTERACTION templates -raws-

			ATTACK templates -raws-

			CASTE template -raws- go here, additionally [DESCRIPTION:#DESC] and [CASTE_NAME:#CASTE_NAME] are added here as well

