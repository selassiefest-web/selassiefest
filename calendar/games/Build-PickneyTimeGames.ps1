#Requires -Version 5.1
<#
    Build-PickneyTimeGames.ps1
    ---------------------------------------------------------------
    Rebuilds the SelassieFest / Pickney Time "Games Archive" as a
    107-game static site: one index.html plus one detail page per
    game, all driven from the single $games data table below.

    Every page now carries a "Share Your Story" call-to-action so the
    global Jamaican diaspora can submit their own photos and memories
    of these games.

    SAFE TO RE-RUN: if a "games" folder already exists next to this
    script, it is renamed to games_backup_<timestamp> before the new
    one is created. Nothing is deleted.
#>

$ErrorActionPreference = "Stop"

# ============================================================
# 0. CONFIG — edit these two lines with your real contact info
# ============================================================
$SubmitEmail    = "selassiefest@gmail.com"
$InstagramTag   = "#PickneyTimeStories"

# Social links shown in every page footer.
$SocialLinks = @(
    @{ Icon='fa-instagram'; Brand=$true;  Url='https://www.instagram.com/selassiefest' },
    @{ Icon='fa-facebook';  Brand=$true;  Url='https://www.facebook.com/profile.php?id=100084954017587' },
    @{ Icon='fa-tiktok';    Brand=$true;  Url='https://www.tiktok.com/@selassiefest' },
    @{ Icon='fa-x-twitter'; Brand=$true;  Url='https://x.com/selassiefest/' },
    @{ Icon='fa-youtube';   Brand=$true;  Url='https://www.youtube.com/@selassie7291' },
    @{ Icon='fa-pinterest'; Brand=$true;  Url='https://www.pinterest.com/himselassie/' },
    @{ Icon='fa-linkedin';  Brand=$true;  Url='https://www.linkedin.com/in/selassiefest/' }
)
$ContactPhone = "414-909-3279"
$footerSocialHtml = ""
foreach ($s in $SocialLinks) {
    $iconClass = if ($s.Brand) { "fab $($s.Icon)" } else { "fas $($s.Icon)" }
    $footerSocialHtml += "<a href=`"$($s.Url)`" target=`"_blank`" rel=`"noopener noreferrer`"><i class=`"$iconClass`"></i></a>`n    "
}

# ============================================================
# 1. PATHS + SAFE BACKUP OF ANY EXISTING "games" FOLDER
# ============================================================
$root      = Split-Path -Parent $MyInvocation.MyCommand.Path
$gamesDir  = Join-Path $root "games"
$backupImagesSource = $null

if (Test-Path $gamesDir) {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupName = "games_backup_$timestamp"
    Write-Host "Existing 'games' folder found -> backing it up as '$backupName' (nothing is deleted)." -ForegroundColor Yellow

    $existingImages = Join-Path $gamesDir "images"
    if (Test-Path $existingImages) {
        $backupImagesSource = Join-Path $root "$backupName\images"
    }

    Rename-Item -Path $gamesDir -NewName $backupName
}
New-Item -ItemType Directory -Path $gamesDir | Out-Null
Write-Host "Created clean folder: $gamesDir" -ForegroundColor Green

if ($backupImagesSource -and (Test-Path $backupImagesSource)) {
    $newImagesDir = Join-Path $gamesDir "images"
    Copy-Item -Path $backupImagesSource -Destination $newImagesDir -Recurse
    $imgCount = (Get-ChildItem -Path $newImagesDir -File).Count
    Write-Host "Carried forward 'images' folder from backup ($imgCount file(s))." -ForegroundColor Green
} else {
    Write-Host "No existing 'images' folder found to carry forward — you'll need to add one." -ForegroundColor Yellow
}

# ============================================================
# 2. CATEGORY FILTER DEFINITIONS (order = filter bar order)
# ============================================================
$categories = @(
    @{ Key='yard';      Label='Yard Games' },
    @{ Key='homemade';  Label='Homemade Toys' },
    @{ Key='ring';      Label='Ring Games' },
    @{ Key='jump';      Label='Jump &amp; Skip' },
    @{ Key='music';     Label='Homemade Music' },
    @{ Key='craft';     Label='Creative Crafts' },
    @{ Key='field-day'; Label='Field Day Games' },
    @{ Key='nature';    Label='Nature &amp; Story Play' },
    @{ Key='rainy';     Label='Rainy Day Play' },
    @{ Key='night';     Label='Night Games' }
)

# ============================================================
# 3. THE 107-GAME DATA TABLE (single source of truth)
# ============================================================
$games = @(
    @{ Title='Anansi Stories'; Slug='anansi-stories'; Category='nature'; CatLabel='Nature & Story Play'; Icon='fa-spider'; Desc='Tales of the trickster spider Anansi, passed down through generations.'; FullDesc='Tales of the trickster spider Anansi, passed down through generations.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Anansi Stories reflects a childhood lived close to the land — where the bush, the yard, and the elders were the classroom.' },
    @{ Title='Bamboo Water Flute'; Slug='bamboo-water-flute'; Category='music'; CatLabel='Homemade Music'; Icon='fa-music'; Desc='A sophisticated homemade acoustic instrument.'; FullDesc='A sophisticated homemade acoustic instrument. A segment of green bamboo is hollowed out, leaving one joint intact to form a chamber. A small fipple mouthpiece is carved at the top. A wooden plunger wrapped in oiled cloth is inserted from the bottom. Pouring a small amount of water inside changes the acoustic resonance, allowing the player to produce beautiful, bird-like warbling slide notes.'; Materials='Green bamboo, a carved wooden rod, a cloth wrap, and water.'; Cultural='The ultimate example of Jamaican playground engineering, blending fluid dynamics, acoustics, and expert woodcraft into a magnificent folk toy.' },
    @{ Title='Banana Bush Sled'; Slug='banana-bush-sled'; Category='yard'; CatLabel='Yard Games'; Icon='fa-mountain'; Desc='The wide, slippery base of a fallen banana tree frond or a large coconut palm branch is stripped of excess leaves.'; FullDesc='The wide, slippery base of a fallen banana tree frond or a large coconut palm branch is stripped of excess leaves. Children sit single-file on the smooth frond base, holding tightly onto the stem, while older friends drag them down muddy, grassy hillsides.'; Materials='A large, fallen banana or coconut tree frond base.'; Cultural='A high-adrenaline, nature-driven pastime that utilized the naturally slick texture of Caribbean vegetation for toboggan-style fun.' },
    @{ Title='Banana Stem Cricket Wickets'; Slug='banana-stem-cricket-wickets'; Category='yard'; CatLabel='Yard Games'; Icon='fa-baseball-bat-ball'; Desc='Improvised sports infrastructure.'; FullDesc='Improvised sports infrastructure. Instead of investing in formal wooden stumps, children cut three vertical slabs from a soft, fibrous, discarded banana tree trunk and stand them upright in the dirt. The soft, fleshy interior of the banana stem makes an excellent wicket because it cleanly absorbs the impact of incoming fast bowls without falling over too easily.'; Materials='Discarded banana tree trunks and a machete (wielded by elders to cut the segments).'; Cultural='Reflects the agricultural landscape of communities surrounded by banana plantations, where farming byproducts provided immediate schoolyard sports gear.' },
    @{ Title='Bat Up and Catch'; Slug='bat-up-and-catch'; Category='yard'; CatLabel='Yard Games'; Icon='fa-baseball'; Desc='An informal, continuous variation of cricket.'; FullDesc='An informal, continuous variation of cricket. One batsman defends a makeshift wicket while a crowd of fielders surrounds them. There are no structured teams; whoever catches the batted ball on the fly immediately wins the right to become the new batsman.'; Materials='A flat wooden plank or coconut frond stem (bat) and a tennis ball.'; Cultural='Reflects the profound democratization of cricket in Jamaica, shifting it from an elite colonial sport to an accessible, community-driven street pastime.' },
    @{ Title='Bearing Skate'; Slug='bearing-skate'; Category='homemade'; CatLabel='Homemade Toys'; Icon='fa-skating'; Desc='A skateboard made from a wooden plank and old bearings.'; FullDesc='A skateboard made from a wooden plank and old bearings.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Bearing Skate is a small monument to "tun yuh han'' mek fashion" — turning whatever was lying around the yard into something worth building, showing off, and passing on.' },
    @{ Title='Bottle Stopper Zinger'; Slug='bottle-stopper-zinger'; Category='homemade'; CatLabel='Homemade Toys'; Icon='fa-compact-disc'; Desc='A spinning flying disc made from a bottle cap and string.'; FullDesc='A spinning flying disc made from a bottle cap and string.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Bottle Stopper Zinger is a small monument to "tun yuh han'' mek fashion" — turning whatever was lying around the yard into something worth building, showing off, and passing on.' },
    @{ Title='Box Guitar'; Slug='box-guitar'; Category='music'; CatLabel='Homemade Music'; Icon='fa-guitar'; Desc='A homemade stringed instrument built by musically inclined children.'; FullDesc='A homemade stringed instrument built by musically inclined children. A large, empty rectangular tin (like a cooking oil or kerosene tin) or a sturdy wooden box serves as the resonator body. A flat piece of bamboo or scrap wood is attached as the neck, and discarded brake cables, thin wire, or fishing lines are stretched across to form strings.'; Materials='An empty tin/wooden box, a wooden plank, wire/fishing line, and a small bridge piece of wood.'; Cultural='Directly tied to the foundations of early Jamaican Mento and Reggae music, showcasing how early musicians and children constructed functional instruments out of scrap metal to express rhythm.' },
    @{ Title='Brown Girl in the Ring'; Slug='brown-girl-in-the-ring'; Category='ring'; CatLabel='Ring Games'; Icon='fa-circle'; Desc='A singing game where children dance in a circle.'; FullDesc='A singing game where children dance in a circle.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Brown Girl in the Ring belongs to a long line of Caribbean ring games sung hand-in-hand — rhythm, memory, and community passed down long before anyone wrote the words on paper.' },
    @{ Title='Bull Inna Pen'; Slug='bull-inna-pen'; Category='yard'; CatLabel='Yard Games'; Icon='fa-running'; Desc='A classic Caribbean game of tag and strategy.'; FullDesc='A classic Caribbean game of tag and strategy.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Like most Jamaican yard games, Bull Inna Pen needed no referee, no equipment budget, and no adult supervision — just an open patch of dirt and whoever showed up that afternoon.' },
    @{ Title='Bull-Roarer'; Slug='bull-roarer'; Category='music'; CatLabel='Homemade Music'; Icon='fa-wind'; Desc='A simple aerodynamic toy that produces a loud, ominous, roaring sound.'; FullDesc='A simple aerodynamic toy that produces a loud, ominous, roaring sound. A flat, notched piece of wood or bamboo is tied tightly to the end of a long string. The child holds the string and whips it through the air in a large circle overhead. The air resistance causes the wood to spin rapidly, creating a deep vibrato hum.'; Materials='A flat piece of wood or bamboo, a knife (for carving notches), and strong twine.'; Cultural='An ancient instrument found across various global indigenous cultures, used in Jamaica as a playful tool to mimic the sound of heavy wind or approaching storms.' },
    @{ Title='Button Yo-Yo'; Slug='button-yo-yo'; Category='homemade'; CatLabel='Homemade Toys'; Icon='fa-compact-disc'; Desc='A classic kinetic toy made from household sewing supplies.'; FullDesc='A classic kinetic toy made from household sewing supplies. A long piece of heavy thread or twine is passed through two opposite holes of a large coat button, and the ends are tied to form a loop. The child holds the ends of the loop, twists the string tight by swinging the button in circles, and then alternately pulls and relaxes their hands to make the button spin at high speeds, creating a humming sound.'; Materials='A large, heavy plastic or wooden button and strong sewing thread.'; Cultural='Found historically across various global folk cultures, this toy was a favorite in Jamaican households due to the easy availability of spare buttons from domestic sewing and mending.' },
    @{ Title='Calabash Cricket Ball'; Slug='calabash-cricket-ball'; Category='homemade'; CatLabel='Homemade Toys'; Icon='fa-baseball'; Desc='A clever modification for street cricket.'; FullDesc='A clever modification for street cricket. When rubber or tennis balls are unavailable, children source a small, immature, unripened calabash gourd. Once dried in the sun, the gourd shrinks into a incredibly dense, lightweight, and perfectly spherical ball that mimics the weight of a standard cricket ball without damaging makeshift wooden bats.'; Materials='A small, immature dried calabash gourd.'; Cultural='Highlights the endless improvisation surrounding cricket in rural communities, utilizing organic forest items to keep the national sport accessible.' },
    @{ Title='Calabash Spinning Bowl'; Slug='calabash-spinning-bowl'; Category='homemade'; CatLabel='Homemade Toys'; Icon='fa-circle-notch'; Desc='A simple, natural kinetic toy.'; FullDesc='A simple, natural kinetic toy. The round, bottom half of a dried calabash fruit is cut and thoroughly scraped clean inside. A smooth, pointed wooden stick is driven through a central hole in the bottom. Children twist the upper part of the stick between their palms, sending the round calabash shell into a smooth, wobbling spin on flat surfaces like a large wooden top.'; Materials='A dried calabash shell and a carved wooden axle stick.'; Cultural='Rooted heavily in Taino and West African domestic crafting traditions, utilizing the hardy, versatile calabash shell for immediate kinetic entertainment.' },
    @{ Title='Cardboard Shadow Box Camera'; Slug='cardboard-shadow-box-camera'; Category='craft'; CatLabel='Creative Crafts'; Icon='fa-camera'; Desc='A toy crafted to mimic the technology of early photographers.'; FullDesc='A toy crafted to mimic the technology of early photographers. Children construct a mock camera out of small cardboard soap boxes. They fit a translucent piece of wax paper inside as a screen and a small pinhole at the front, mapping basic light projections and playing the role of community journalists.'; Materials='Discarded cardboard boxes, wax paper, and pins.'; Cultural='Displays the fascination with mid-20th-century media expansions in Jamaica, showing how children structurally integrated modern technology into traditional roleplay.' },
    @{ Title='Cat''s Cradle'; Slug='cats-cradle'; Category='craft'; CatLabel='Creative Crafts'; Icon='fa-diagram-project'; Desc='A loop of colorful string is woven around a player''s fingers.'; FullDesc='A loop of colorful string is woven around a player''s fingers. Through a series of intricate loops, twists, and expansions, they create complex geometric patterns (like "Eiffel Tower" or "Fish Net") before transferring the design intact to a partner''s fingers.'; Materials='A 3-foot loop of yarn or twine string.'; Cultural='A globally shared game that, in Jamaica, encouraged quiet focus, digital dexterity, and collaborative geometry modeling.' },
    @{ Title='Catch-a-Base'; Slug='catch-a-base'; Category='yard'; CatLabel='Yard Games'; Icon='fa-baseball'; Desc='A game of running, tagging, and teamwork.'; FullDesc='A game of running, tagging, and teamwork.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Like most Jamaican yard games, Catch-a-Base needed no referee, no equipment budget, and no adult supervision — just an open patch of dirt and whoever showed up that afternoon.' },
    @{ Title='Catching Lizards with Grass Straws'; Slug='catching-lizards'; Category='nature'; CatLabel='Nature & Story Play'; Icon='fa-paw'; Desc='A patient, nature-oriented game of skill.'; FullDesc='A patient, nature-oriented game of skill. Children search for common garden lizards (Anoles). They fashion a small slipknot at the end of a long, flexible blade of elephant grass or a coconut bough vein, gently sliding the loop over the lizard''s head to catch it harmlessly.'; Materials='A long blade of grass or coconut frond fiber.'; Cultural='Reflects an intimate connection with nature, teaching fine-motor steadiness, tracking, and wilderness patience.' },
    @{ Title='Checkers'; Slug='checkers'; Category='yard'; CatLabel='Yard Games'; Icon='fa-chess'; Desc='A strategic board game played in yards across the Caribbean.'; FullDesc='A strategic board game played in yards across the Caribbean.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Like most Jamaican yard games, Checkers needed no referee, no equipment budget, and no adult supervision — just an open patch of dirt and whoever showed up that afternoon.' },
    @{ Title='Chick, Chick, Chick'; Slug='chick-chick-chick'; Category='ring'; CatLabel='Ring Games'; Icon='fa-feather'; Desc='A dramatic narrative game.'; FullDesc='A dramatic narrative game. One player is the "Mother Hen," protecting a long, single-file line of "chicks" holding each other''s waists behind her. Another player is the "Bull" or "Hawk" who taunts the hen and attempts to dart past her wings to snatch a chick from the back of the line.'; Materials='None.'; Cultural='Deeply allegorical, illustrating family protection, rural farm dynamics, and communal defense against predators.' },
    @{ Title='Chinese Skip'; Slug='chinese-skip'; Category='jump'; CatLabel='Jump & Skip'; Icon='fa-link'; Desc='A stretchy elastic rope game of jumps, tricks, and quick feet.'; FullDesc='A stretchy elastic rope game of jumps, tricks, and quick feet.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Chinese Skip turned rhythm and footwork into a competition every child wanted to win — and every big sister was unbeatable at.' },
    @{ Title='Coconut Leaf Weaving'; Slug='coconut-leaf-weaving'; Category='craft'; CatLabel='Creative Crafts'; Icon='fa-dove'; Desc='A quiet, artistic craft game.'; FullDesc='A quiet, artistic craft game. Children harvest long, pliable green pinnate leaflets from a fallen coconut palm frond. Through a series of traditional, interlinking over-and-under folds passed down by elders, they weave the leaf into functional toy birds, small baskets, or decorative watches and crowns.'; Materials='Fresh green coconut palm leaflets.'; Cultural='Preserves indigenous and West African structural craft traditions, transforming common yard foliage into temporary, intricately designed sculptural toys.' },
    @{ Title='Coconut Shell Shuffle'; Slug='coconut-shell-shuffle'; Category='music'; CatLabel='Homemade Music'; Icon='fa-drum'; Desc='A simple rhythmic noise-maker.'; FullDesc='A simple rhythmic noise-maker. Children take two halves of a clean, dried, hard coconut shell and drill a small hole through the center of each. A piece of twine is threaded through to create handles. By clapping the two hard shells together or striking them against the ground in sequence, children create a loud, distinct horse-hoof sound to accompany street songs.'; Materials='Two dried coconut shell halves and twine.'; Cultural='A clear example of using agricultural byproduct for immediate rhythmic expression, heavily utilized in rural storytelling gatherings and impromptu schoolyard bands.' },
    @{ Title='Coconut Stalk Truck'; Slug='coconut-stalk-truck'; Category='homemade'; CatLabel='Homemade Toys'; Icon='fa-truck'; Desc='A pull-along toy truck carved from a dried coconut branch stalk.'; FullDesc='A pull-along toy truck carved from a dried coconut branch stalk.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Coconut Stalk Truck is a small monument to "tun yuh han'' mek fashion" — turning whatever was lying around the yard into something worth building, showing off, and passing on.' },
    @{ Title='Coconut Tree Climber Race'; Slug='coconut-tree-climber-race'; Category='field-day'; CatLabel='Field Day Games'; Icon='fa-tree'; Desc='A highly athletic, traditional test of strength played among older children in rural coastal areas.'; FullDesc='A highly athletic, traditional test of strength played among older children in rural coastal areas. Two competitors race to see who can scale a straight, marked coconut palm tree to a safe height using traditional foot-binding techniques (wrapping a cloth loop around the feet to grip the trunk).'; Materials='A sturdy, mature coconut tree and a strong strip of cloth or burlap rope.'; Cultural='Directly tied to the agricultural skills of rural Jamaica, where gathering coconuts for water, jelly, and oil required immense physical agility and specialized climbing techniques.' },
    @{ Title='Condensed Milk Tin Lantern'; Slug='condensed-milk-tin-lantern'; Category='homemade'; CatLabel='Homemade Toys'; Icon='fa-fire'; Desc='A beautifully atmospheric evening toy.'; FullDesc='A beautifully atmospheric evening toy. Older children take an empty, clean condensed milk tin and punch intricate geometric patterns into the sides using a nail. A wire handle is attached. On dark nights, a small candle or safe light source is placed inside, casting intricate, glowing patterns across yard walls as the child carries it.'; Materials='Empty tin can, a hammer, a nail, and a wire handle.'; Cultural='Inspired by traditional Jamaican *Flambeau* torches and evening storytelling lamps, this toy allowed children to create their own visual light theater before electricity arrived in rural parishes.' },
    @{ Title='Condensed Milk Tin Phone'; Slug='condensed-milk-tin-phone'; Category='homemade'; CatLabel='Homemade Toys'; Icon='fa-phone'; Desc='Two empty, clean tin cans have a small hole punched through the center of their bases.'; FullDesc='Two empty, clean tin cans have a small hole punched through the center of their bases. A long piece of taut twine string is threaded through and secured with knots. When two children stand far apart keeping the string taut, acoustic sound vibrations travel down the line, functioning as a mechanical telephone.'; Materials='Two empty condensed milk tins, long twine string.'; Cultural='A fun, tactile introduction to acoustic physics, utilizing a ubiquitous household staple (condensed milk used for Jamaican porridge and tea).' },
    @{ Title='Cuffum (Water Slapping)'; Slug='cuffum'; Category='yard'; CatLabel='Yard Games'; Icon='fa-water'; Desc='A rhythmic game played by children swimming in rivers, seas, or deep gullies.'; FullDesc='A rhythmic game played by children swimming in rivers, seas, or deep gullies. By cupping their hands in a specific configuration and striking the surface of the water with force, players create distinct, deep, hollow percussive notes. Children compete to see who can create the loudest resonance or maintain a steady reggae or mento drumbeat in the water.'; Materials='None (requires a natural body of water).'; Cultural='Showcases a creative mastery of the natural environment, turning bodies of water into acoustic musical spaces using specialized physical techniques passed down through generations.' },
    @{ Title='Dandy Shandy'; Slug='dandy-shandy'; Category='yard'; CatLabel='Yard Games'; Icon='fa-running'; Desc='A fast-paced chase game that builds speed and agility.'; FullDesc='A fast-paced chase game that builds speed and agility.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Like most Jamaican yard games, Dandy Shandy needed no referee, no equipment budget, and no adult supervision — just an open patch of dirt and whoever showed up that afternoon.' },
    @{ Title='Dominoes'; Slug='dominoes'; Category='yard'; CatLabel='Yard Games'; Icon='fa-dice'; Desc='The beloved Caribbean pastime — clash with friends and family.'; FullDesc='The beloved Caribbean pastime — clash with friends and family.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Like most Jamaican yard games, Dominoes needed no referee, no equipment budget, and no adult supervision — just an open patch of dirt and whoever showed up that afternoon.' },
    @{ Title='Drink Box Truck'; Slug='drink-box-truck'; Category='homemade'; CatLabel='Homemade Toys'; Icon='fa-truck'; Desc='A toy truck made from a milk carton and bottle caps.'; FullDesc='A toy truck made from a milk carton and bottle caps.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Drink Box Truck is a small monument to "tun yuh han'' mek fashion" — turning whatever was lying around the yard into something worth building, showing off, and passing on.' },
    @{ Title='Eeh Yow'; Slug='eeh-yow'; Category='ring'; CatLabel='Ring Games'; Icon='fa-circle'; Desc='A fast-paced ring game with clapping and laughter.'; FullDesc='A fast-paced ring game with clapping and laughter.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Eeh Yow belongs to a long line of Caribbean ring games sung hand-in-hand — rhythm, memory, and community passed down long before anyone wrote the words on paper.' },
    @{ Title='Elder Storytelling'; Slug='elder-storytelling'; Category='nature'; CatLabel='Nature & Story Play'; Icon='fa-users'; Desc='Elders share stories of childhood, community, and tradition.'; FullDesc='Elders share stories of childhood, community, and tradition.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Elder Storytelling reflects a childhood lived close to the land — where the bush, the yard, and the elders were the classroom.' },
    @{ Title='Emmanuel Road'; Slug='emmanuel-road'; Category='ring'; CatLabel='Ring Games'; Icon='fa-road'; Desc='A call-and-response ring game celebrating community and rhythm.'; FullDesc='A call-and-response ring game celebrating community and rhythm.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Emmanuel Road belongs to a long line of Caribbean ring games sung hand-in-hand — rhythm, memory, and community passed down long before anyone wrote the words on paper.' },
    @{ Title='Firefly Tin'; Slug='firefly-tin'; Category='nature'; CatLabel='Nature & Story Play'; Icon='fa-lightbulb'; Desc='A magical nighttime activity.'; FullDesc='A magical nighttime activity. During summer evenings, children gather empty glass jars or clean plastic containers and punch tiny air holes in the lids. They hunt in the bushes for *Peenie Wallies* (large click beetles with glowing green eye-spots) or *Blinkies* (traditional fireflies), gently trapping them to create an organic, glowing lantern that illuminates their bedrooms for an hour before the insects are released back into the wild.'; Materials='A clean container, a nail for air holes, and local bioluminescent insects.'; Cultural='Celebrated in classic Jamaican folk songs ("Peenie Wallie, Peenie Wallie, look at dem shine..."), this activity fostered a deep appreciation for nighttime ecology and oral folklore.' },
    @{ Title='Gig Building'; Slug='gig-building'; Category='homemade'; CatLabel='Homemade Toys'; Icon='fa-music'; Desc='A simple instrument made from a tin can and string.'; FullDesc='A simple instrument made from a tin can and string.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Gig Building is a small monument to "tun yuh han'' mek fashion" — turning whatever was lying around the yard into something worth building, showing off, and passing on.' },
    @{ Title='Gourd Rattle (Shakka)'; Slug='gourd-rattle'; Category='music'; CatLabel='Homemade Music'; Icon='fa-music'; Desc='A homemade percussion instrument.'; FullDesc='A homemade percussion instrument. Children forage for small, dried wild gourds or calabash fruits that have fallen from trees. They drill a small hole into the side, insert a handful of small river pebbles, dried corn kernels, or wild seeds, and plug the hole with a carved wooden peg to create a functional rhythmic shaker.'; Materials='A small dried gourd, small pebbles or seeds, and a wooden plug.'; Cultural='Strongly rooted in West African musical traditions, this toy directly links children''s playcraft with the construction principles of traditional Caribbean percussion instruments like maracas.' },
    @{ Title='Hand Ball'; Slug='hand-ball'; Category='yard'; CatLabel='Yard Games'; Icon='fa-hand-fist'; Desc='A hybrid of baseball and cricket rules.'; FullDesc='A hybrid of baseball and cricket rules. A pitcher throws a soft, stuffed makeshift ball toward a batsman. Instead of using a wooden bat, the batsman uses the open, flat palm of their hand to strike the ball before sprinting across marked bases (trees or large rocks).'; Materials='Stuffed juice cartons or old tennis balls.'; Cultural='Created spontaneously when formal sports equipment was unavailable, showcasing the adaptive sports culture of rural schoolyards.' },
    @{ Title='Hide and Seek'; Slug='hide-and-seek'; Category='yard'; CatLabel='Yard Games'; Icon='fa-eye'; Desc='A classic game adapted to rural landscape features.'; FullDesc='A classic game adapted to rural landscape features. A seeker covers their eyes and counts to a designated number near a central base tree. Players scatter to hide behind massive mango trunks, banana groves, or thick bushes. The seeker must find them and race back to the base tree to tag them out.'; Materials='An expansive yard filled with natural coverage.'; Cultural='Celebrated the natural environment of Jamaica, teaching stealth, land familiarity, and spatial strategy under the cover of dusk.' },
    @{ Title='Hog Plum Top'; Slug='hog-plum-top'; Category='homemade'; CatLabel='Homemade Toys'; Icon='fa-compact-disc'; Desc='A miniature version of the wooden gig.'; FullDesc='A miniature version of the wooden gig. Children harvest the hard, deeply wrinkled, pitted inner stones of the native hog plum (*Spondias mombin*) fruit. They drive a sharp wooden matchstick or toothpick straight through the center of the seed, creating a tiny, perfectly balanced spinning top that can spin for minutes on smooth veranda tiles.'; Materials='A dried hog plum seed and a small wooden splinter.'; Cultural='A gentle, domestic micro-craft that provided indoor entertainment for younger children using nothing but seasonal organic seeds.' },
    @{ Title='Hopscotch (Strepa)'; Slug='hopscotch-strepa'; Category='jump'; CatLabel='Jump & Skip'; Icon='fa-shoe-prints'; Desc='Toss a stone and hop through the numbered grid without missing a beat.'; FullDesc='Toss a stone and hop through the numbered grid without missing a beat.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Hopscotch (Strepa) turned rhythm and footwork into a competition every child wanted to win — and every big sister was unbeatable at.' },
    @{ Title='Hose Hoop Wheel'; Slug='hose-hoop-wheel'; Category='homemade'; CatLabel='Homemade Toys'; Icon='fa-circle'; Desc='A rolling wheel made from an old hose and a stick.'; FullDesc='A rolling wheel made from an old hose and a stick.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Hose Hoop Wheel is a small monument to "tun yuh han'' mek fashion" — turning whatever was lying around the yard into something worth building, showing off, and passing on.' },
    @{ Title='Inches'; Slug='inches'; Category='yard'; CatLabel='Yard Games'; Icon='fa-ruler'; Desc='A competitive jumping and spacing game.'; FullDesc='A competitive jumping and spacing game. Players must leap from a fixed line over an ever-increasing physical span or marker. The distances are meticulously bartered, negotiated, and measured in literal "inches" using hand spans or foot lengths.'; Materials='Sticks or scratched dirt marks.'; Cultural='Emphasized grassroots mathematics, bodily precision, and playful peer-to-peer negotiation.' },
    @{ Title='Jacks'; Slug='jacks'; Category='yard'; CatLabel='Yard Games'; Icon='fa-hand-peace'; Desc='A classic hand-eye coordination game played with small metal pieces.'; FullDesc='A classic hand-eye coordination game played with small metal pieces.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Like most Jamaican yard games, Jacks needed no referee, no equipment budget, and no adult supervision — just an open patch of dirt and whoever showed up that afternoon.' },
    @{ Title='Jamaican Sayings'; Slug='jamaican-sayings'; Category='nature'; CatLabel='Nature & Story Play'; Icon='fa-comment-dots'; Desc='Everyday sayings that reflect Caribbean culture and humor.'; FullDesc='Everyday sayings that reflect Caribbean culture and humor.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Jamaican Sayings reflects a childhood lived close to the land — where the bush, the yard, and the elders were the classroom.' },
    @{ Title='Jane &amp; Louisa'; Slug='jane-and-louisa'; Category='ring'; CatLabel='Ring Games'; Icon='fa-circle'; Desc='A ring game passed hand to hand with song and gentle movement.'; FullDesc='A ring game passed hand to hand with song and gentle movement.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Jane &amp; Louisa belongs to a long line of Caribbean ring games sung hand-in-hand — rhythm, memory, and community passed down long before anyone wrote the words on paper.' },
    @{ Title='Juice Box Roller'; Slug='juice-box-roller'; Category='homemade'; CatLabel='Homemade Toys'; Icon='fa-train'; Desc='A kinetic pull-toy designed for toddlers.'; FullDesc='A kinetic pull-toy designed for toddlers. Multiple empty juice boxes are linked together in a long chain using wire or string, with bottle-cap wheels attached to each unit to form a multi-segmented rolling train.'; Materials='Cardboard cartons, caps, wire, string.'; Cultural='A toy built by older siblings to entertain younger toddlers, fostering familial craftsmanship and creative play.' },
    @{ Title='June Bug on a String'; Slug='june-bug-on-a-string'; Category='nature'; CatLabel='Nature & Story Play'; Icon='fa-bug'; Desc='A seasonal kinetic toy.'; FullDesc='A seasonal kinetic toy. During the heavy rains of May and June, large brown *June Bugs* (May beetles) emerge in abundance. Children gently tie a long, lightweight sewing thread around one of the beetle''s rear legs. When the beetle takes flight, it flies in smooth, continuous concentric circles overhead, functioning like a living, miniature mechanical airplane or kite.'; Materials='A piece of sewing thread and a seasonal June Bug.'; Cultural='A classic rural rite of passage that turned seasonal insect migrations into interactive, low-cost engineering play.' },
    @{ Title='Kite Making'; Slug='kite-making'; Category='homemade'; CatLabel='Homemade Toys'; Icon='fa-wind'; Desc='Build and fly kites from paper, sticks, and string.'; FullDesc='Build and fly kites from paper, sticks, and string.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Kite Making is a small monument to "tun yuh han'' mek fashion" — turning whatever was lying around the yard into something worth building, showing off, and passing on.' },
    @{ Title='Leaf Boats'; Slug='leaf-boats'; Category='rainy'; CatLabel='Rainy Day Play'; Icon='fa-water'; Desc='During heavy tropical afternoon rain showers, children gather at the sides of the road where rushing rainwater forms miniature rivers in…'; FullDesc='During heavy tropical afternoon rain showers, children gather at the sides of the road where rushing rainwater forms miniature rivers in the gutters. They fold sturdy mango or sea-grape leaves into buoyant miniature boats and race them down the gully streams.'; Materials='Fallen mango leaves or almond leaves.'; Cultural='Celebrated the tropical climate, transforming seasonal rainfall into a canvas for aquatic racing and community play.' },
    @{ Title='Leapfrog'; Slug='leapfrog'; Category='jump'; CatLabel='Jump & Skip'; Icon='fa-frog'; Desc='Crouch, leap, and bound over your friends in this playground classic.'; FullDesc='Crouch, leap, and bound over your friends in this playground classic.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Leapfrog turned rhythm and footwork into a competition every child wanted to win — and every big sister was unbeatable at.' },
    @{ Title='Lemon Tree (Hand Clapping)'; Slug='lemon-tree'; Category='ring'; CatLabel='Ring Games'; Icon='fa-hands-clapping'; Desc='A classic, high-tempo partner hand-clapping game.'; FullDesc='A classic, high-tempo partner hand-clapping game. Two players face each other, executing a complex sequence of cross-clapping, thigh-slapping, and hand-twisting motions that sync perfectly with a lyrical narrative.'; Materials='None.'; Cultural='Fostered exceptional polyrhythmic coordination, focus, and verbal agility among schoolgirls during recess.' },
    @{ Title='Lime and Spoon Race'; Slug='lime-and-spoon-race'; Category='field-day'; CatLabel='Field Day Games'; Icon='fa-utensils'; Desc='A highly anticipated balance and coordination race featured at school sports days.'; FullDesc='A highly anticipated balance and coordination race featured at school sports days. Competitors line up at a starting mark, each holding the handle of a metal spoon in their mouth. A small green lime is balanced in the bowl of the spoon. At the whistle, players must sprint or fast-walk to the finish line without dropping the lime; if it falls, they must stop, replace it, or face elimination.'; Materials='Metal tablespoons and fresh, small green limes.'; Cultural='Adapted from traditional British "egg and spoon" races, Jamaicans substituted local limes, turning it into a classic test of focus and physical composure.' },
    @{ Title='Lime Football'; Slug='lime-football'; Category='yard'; CatLabel='Yard Games'; Icon='fa-futbol'; Desc='An impromptu version of soccer played in tight spaces like narrow lanes or school corridors.'; FullDesc='An impromptu version of soccer played in tight spaces like narrow lanes or school corridors. In the absence of a leather football, children use a small, hard green lime or an empty, flattened aluminum juice can as the ball. The game emphasizes close-control dribbling and precise passing rather than long kicks.'; Materials='A fresh lime or a discarded, flattened aluminum can.'; Cultural='Highlights the unyielding popularity of football (soccer) in Jamaican culture and the immediate improvisation of equipment to play the sport regardless of urban constraints.' },
    @{ Title='Little Miss Nancy'; Slug='little-miss-nancy'; Category='ring'; CatLabel='Ring Games'; Icon='fa-circle'; Desc='A ring game with songs and playful movement.'; FullDesc='A ring game with songs and playful movement.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Little Miss Nancy belongs to a long line of Caribbean ring games sung hand-in-hand — rhythm, memory, and community passed down long before anyone wrote the words on paper.' },
    @{ Title='Ludi'; Slug='ludi'; Category='yard'; CatLabel='Yard Games'; Icon='fa-dice'; Desc='A classic Caribbean board game of strategy and luck.'; FullDesc='A classic Caribbean board game of strategy and luck.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Like most Jamaican yard games, Ludi needed no referee, no equipment budget, and no adult supervision — just an open patch of dirt and whoever showed up that afternoon.' },
    @{ Title='Mango Stone Skee-Ball'; Slug='mango-stone-skee-ball'; Category='yard'; CatLabel='Yard Games'; Icon='fa-bullseye'; Desc='A seasonal accuracy game.'; FullDesc='A seasonal accuracy game. After eating juicy kidney or hairy mangoes, children wash and dry the large, fibrous inner seeds (stones). They dig a series of three small holes in sloping dirt, assigning higher point values to the furthest holes. From a baseline, they slide or roll the flat mango stones across the earth trying to score.'; Materials='Dried, fibrous mango stones and a dirt surface.'; Cultural='Ensures that nothing from the abundant tropical mango harvest goes to waste, turning organic orchard debris into an immediate math and motor skill game.' },
    @{ Title='Marbles'; Slug='marbles'; Category='yard'; CatLabel='Yard Games'; Icon='fa-circle'; Desc='Knuckle down and aim true — marbles is a game of precision.'; FullDesc='Knuckle down and aim true — marbles is a game of precision.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Like most Jamaican yard games, Marbles needed no referee, no equipment budget, and no adult supervision — just an open patch of dirt and whoever showed up that afternoon.' },
    @{ Title='Matchbox Gun'; Slug='matchbox-gun'; Category='homemade'; CatLabel='Homemade Toys'; Icon='fa-gun'; Desc='A homemade cap gun built from a matchbox and rubber bands.'; FullDesc='A homemade cap gun built from a matchbox and rubber bands.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Matchbox Gun is a small monument to "tun yuh han'' mek fashion" — turning whatever was lying around the yard into something worth building, showing off, and passing on.' },
    @{ Title='Matchbox Slide Camera'; Slug='matchbox-slide-camera'; Category='craft'; CatLabel='Creative Crafts'; Icon='fa-film'; Desc='A popular miniature interactive toy.'; FullDesc='A popular miniature interactive toy. Children take an empty matchbox and draw a long, continuous comic strip of illustrations on a strip of paper. They thread the paper strip through the inner drawer of the matchbox, sliding it along to show a moving "movie" or slideshow through a small window cut in the outer sleeve.'; Materials='An empty matchbox, paper strips, and pencils/crayons.'; Cultural='Encouraged illustration, visual narrative sequence, and early cinematic concepts using basic household matches packaging.' },
    @{ Title='Matchbox Train'; Slug='matchbox-train'; Category='homemade'; CatLabel='Homemade Toys'; Icon='fa-train'; Desc='A tiny, multi-segmented pull-toy built by younger children.'; FullDesc='A tiny, multi-segmented pull-toy built by younger children. Empty wooden or cardboard matchboxes are linked together end-to-end using thread or wire. Small pebbles or dried seeds are placed inside each drawer as "cargo," and the train is pulled along the floor or across dirt pathways.'; Materials='Empty matchboxes, thread or thin wire, and small seeds or pebbles.'; Cultural='A domestic toy that encouraged imaginative narrative play and early mechanical coordination among toddlers using small household containers.' },
    @{ Title='Miss Mary Mack'; Slug='miss-mary-mack'; Category='ring'; CatLabel='Ring Games'; Icon='fa-hands-clapping'; Desc='A widely adapted hand-clapping game across the African diaspora.'; FullDesc='A widely adapted hand-clapping game across the African diaspora. Jamaican school children modified the rhythm with distinct syncopated beats and patois vocal inflections, clapping palms in a fast, crisscross pattern.'; Materials='None.'; Cultural='Highlights the shared cultural retentions and linguistic evolutions across the Caribbean and African-American children''s play traditions.' },
    @{ Title='Moonlight Shiny'; Slug='moonlight-shiny'; Category='night'; CatLabel='Night Games'; Icon='fa-moon'; Desc='A poetic version of hide-and-seek played exclusively at night under a full moon.'; FullDesc='A poetic version of hide-and-seek played exclusively at night under a full moon. The seeker stands at a central base and chants to signal the start of the search. Because shadows are long and deceptive in the moonlight, players must use stealth, crawling through tall guinea grass or behind outbuildings to make it back to the base without being spotted and named. - **Chant:** "Moonlight shiny, ketch mi if yuh can!"'; Materials='None (requires an expansive yard on a bright, moonlit night).'; Cultural='Originating in rural, pre-electricity Jamaica, this game transformed the night into a safe, communal playground, reinforcing a deep familiarity with the local landscape.' },
    @{ Title='Mother May I'; Slug='mother-may-i'; Category='yard'; CatLabel='Yard Games'; Icon='fa-people-arrows'; Desc='A game of asking permission and taking steps forward.'; FullDesc='A game of asking permission and taking steps forward.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Like most Jamaican yard games, Mother May I needed no referee, no equipment budget, and no adult supervision — just an open patch of dirt and whoever showed up that afternoon.' },
    @{ Title='Mud Brick Modeling'; Slug='mud-brick-modeling'; Category='craft'; CatLabel='Creative Crafts'; Icon='fa-cube'; Desc='A creative construction pastime common in rural areas after heavy rains.'; FullDesc='A creative construction pastime common in rural areas after heavy rains. Children mix red clay earth with water to the ideal consistency, shape the mud into uniform rectangular blocks using small matchboxes or wood scraps as molds, and leave them to dry in the sun. The resulting "bricks" are used to build miniature houses, castles, and miniature animal pens.'; Materials='Natural clay/dirt, water, and small containers for molds.'; Cultural='Fostered early tactile creativity and spatial design, mimicking the traditional wattle-and-daub or brick-and-mortar building techniques observed in rural Jamaican architecture.' },
    @{ Title='Muma Lashie'; Slug='muma-lashie'; Category='ring'; CatLabel='Ring Games'; Icon='fa-circle'; Desc='A dramatic chasing game centered around family rules.'; FullDesc='A dramatic chasing game centered around family rules. One child acts as "Muma Lashie," a strict parent figure guarding a base. The other children play chores or misbehaving children who taunt Muma Lashie by creeping closer and closer to the base. When Muma Lashie turns around to "lash" (tag) them, they must sprint back to their safety lines.'; Materials='None.'; Cultural='Explores traditional household structures and parental authority in Caribbean family dynamics through playful, highly energetic roleplay.' },
    @{ Title='Nanny Goat Nesting'; Slug='nanny-goat-nesting'; Category='nature'; CatLabel='Nature & Story Play'; Icon='fa-bug'; Desc='Children locate the small, conical sand craters dug by antlion larvae in dry dirt yards.'; FullDesc='Children locate the small, conical sand craters dug by antlion larvae in dry dirt yards. They gently stir the loose earth with a finger or straw while chanting folklore rhymes to coax the harmless insect to surface.'; Materials='Loose dirt, a straw.'; Cultural='A charming rural tradition that turned entomological curiosity into interactive folklore storytelling.' },
    @{ Title='Needle and Thread (Target Throw)'; Slug='needle-and-thread-target-throw'; Category='yard'; CatLabel='Yard Games'; Icon='fa-bullseye'; Desc='A yard game focusing on fine-motor precision.'; FullDesc='A yard game focusing on fine-motor precision. A small, narrow-necked glass bottle is placed on the ground. Players stand several feet back and hold a length of string with a small nail or heavy needle tied to the bottom. Swinging the string like a pendulum, they attempt to drop the nail cleanly into the narrow mouth of the bottle.'; Materials='A glass bottle, string, and a small iron nail.'; Cultural='Taught spatial judgment, steady hand control, and patience, serving as a quiet, competitive game played on verandas during rainy days.' },
    @{ Title='Night Games'; Slug='night-games'; Category='night'; CatLabel='Night Games'; Icon='fa-moon'; Desc='Games that come alive under the stars — flashlight tag, shadows, and more.'; FullDesc='Games that come alive under the stars — flashlight tag, shadows, and more.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Night Games belongs to that particular magic of Jamaican nights — when the yard changed shape in the dark and every shadow was worth chasing.' },
    @{ Title='One and Twenty'; Slug='one-and-twenty'; Category='ring'; CatLabel='Ring Games'; Icon='fa-hashtag'; Desc='A synchronized counting game.'; FullDesc='A synchronized counting game. Players stand back-to-back or in a circle, executing coordinated physical gestures (like jumps or claps) while keeping a strict numerical count up to twenty-one. Mistakes in rhythm reset the count.'; Materials='None.'; Cultural='Used to reinforce mathematical agility and bodily synchronization outside the formal classroom setting.' },
    @{ Title='Orange Peel Twister'; Slug='orange-peel-twister'; Category='craft'; CatLabel='Creative Crafts'; Icon='fa-lemon'; Desc='A fragrant, creative pastime common during citrus season.'; FullDesc='A fragrant, creative pastime common during citrus season. Children attempt to peel a whole sweet orange or tangerine in a single, continuous, unbroken spiral ribbon using their fingernails or a small dull knife. The resulting spiral is then carefully dried or manipulated into decorative shapes, rosettes, or toy snakes.'; Materials='Fresh oranges or tangerines.'; Cultural='Fostered fine motor control, patience, and a sensory appreciation for local fruits, turning the process of eating a snack into an artistic challenge.' },
    @{ Title='Paper Pinwheel'; Slug='paper-pinwheel'; Category='homemade'; CatLabel='Homemade Toys'; Icon='fa-fan'; Desc='A spinning paper toy that dances and twirls in the breeze.'; FullDesc='A spinning paper toy that dances and twirls in the breeze.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Paper Pinwheel is a small monument to "tun yuh han'' mek fashion" — turning whatever was lying around the yard into something worth building, showing off, and passing on.' },
    @{ Title='Paper Plane'; Slug='paper-plane'; Category='homemade'; CatLabel='Homemade Toys'; Icon='fa-paper-plane'; Desc='The art of folding and launching paper aircraft.'; FullDesc='The art of folding and launching paper aircraft.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Paper Plane is a small monument to "tun yuh han'' mek fashion" — turning whatever was lying around the yard into something worth building, showing off, and passing on.' },
    @{ Title='Pawpaw Stem Flute'; Slug='pawpaw-stem-flute'; Category='music'; CatLabel='Homemade Music'; Icon='fa-music'; Desc='A temporary woodwind instrument made from nature.'; FullDesc='A temporary woodwind instrument made from nature. Children harvest a hollow, green stem from a papaya (pawpaw) leaf. They carefully slice a small, angled slit near one closed end to act as a reed or fipple. Blowing through the stem produces a high-pitched, trumpet-like tone. Advanced players cut small finger holes along the length to change the pitch.'; Materials='Fresh, hollow papaya leaf stems.'; Cultural='Demonstrates an intimate understanding of the natural properties of Caribbean flora, transforming everyday yard forage into acoustic entertainment.' },
    @{ Title='Pear Gun'; Slug='pear-gun'; Category='homemade'; CatLabel='Homemade Toys'; Icon='fa-water-gun'; Desc='A playful toy gun made from a pear-shaped gourd.'; FullDesc='A playful toy gun made from a pear-shaped gourd.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Pear Gun is a small monument to "tun yuh han'' mek fashion" — turning whatever was lying around the yard into something worth building, showing off, and passing on.' },
    @{ Title='Pop Shot'; Slug='pop-shot'; Category='homemade'; CatLabel='Homemade Toys'; Icon='fa-bullseye'; Desc='A shooting game using a homemade launcher and targets.'; FullDesc='A shooting game using a homemade launcher and targets.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Pop Shot is a small monument to "tun yuh han'' mek fashion" — turning whatever was lying around the yard into something worth building, showing off, and passing on.' },
    @{ Title='Proverbs'; Slug='proverbs'; Category='nature'; CatLabel='Nature & Story Play'; Icon='fa-quote-left'; Desc='Jamaican proverbs that carry wisdom and life lessons.'; FullDesc='Jamaican proverbs that carry wisdom and life lessons.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Proverbs reflects a childhood lived close to the land — where the bush, the yard, and the elders were the classroom.' },
    @{ Title='Puncienella Likkle Fella'; Slug='puncienella-likkle-fella'; Category='ring'; CatLabel='Ring Games'; Icon='fa-circle'; Desc='A joyous ring game with call-and-response singing.'; FullDesc='A joyous ring game with call-and-response singing.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Puncienella Likkle Fella belongs to a long line of Caribbean ring games sung hand-in-hand — rhythm, memory, and community passed down long before anyone wrote the words on paper.' },
    @{ Title='Purple Touch'; Slug='purple-touch'; Category='yard'; CatLabel='Yard Games'; Icon='fa-hand-pointer'; Desc='A localized tag variation with strict parameters.'; FullDesc='A localized tag variation with strict parameters. The player designated as "It" must tag others exclusively on a specifically declared body part or clothing color (historically starting with the color purple, though variants exist). Evasion requires keeping that specific target out of reach.'; Materials='None.'; Cultural='A schoolyard game requiring rapid visual processing and precision tagging under pressure.' },
    @{ Title='Push Cart'; Slug='push-cart'; Category='homemade'; CatLabel='Homemade Toys'; Icon='fa-cart-shopping'; Desc='A wooden cart built from scraps, perfect for hauling treasures.'; FullDesc='A wooden cart built from scraps, perfect for hauling treasures.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Push Cart is a small monument to "tun yuh han'' mek fashion" — turning whatever was lying around the yard into something worth building, showing off, and passing on.' },
    @{ Title='Rainy Day Play'; Slug='rainy-day-play'; Category='rainy'; CatLabel='Rainy Day Play'; Icon='fa-cloud-rain'; Desc='Indoor games and activities for rainy afternoons.'; FullDesc='Indoor games and activities for rainy afternoons.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='When the rain kept everyone indoors, Rainy Day Play is one of the ways Jamaican children turned a washed-out afternoon into a memory.' },
    @{ Title='Red Light Green Light'; Slug='red-light-green-light'; Category='yard'; CatLabel='Yard Games'; Icon='fa-traffic-light'; Desc='A universal game of movement and control.'; FullDesc='A universal game of movement and control.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Like most Jamaican yard games, Red Light Green Light needed no referee, no equipment budget, and no adult supervision — just an open patch of dirt and whoever showed up that afternoon.' },
    @{ Title='Riddles'; Slug='riddles'; Category='yard'; CatLabel='Yard Games'; Icon='fa-brain'; Desc='Test your wit with Caribbean riddles and proverbs.'; FullDesc='Test your wit with Caribbean riddles and proverbs.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Like most Jamaican yard games, Riddles needed no referee, no equipment budget, and no adult supervision — just an open patch of dirt and whoever showed up that afternoon.' },
    @{ Title='Ring on a String'; Slug='ring-on-a-string'; Category='craft'; CatLabel='Creative Crafts'; Icon='fa-ring'; Desc='A quiet, deceptive parlor and veranda game.'; FullDesc='A quiet, deceptive parlor and veranda game. A long piece of string is threaded through a simple metal ring or button, and the ends are tied together. Players stand in a circle holding onto the string with both hands. One player stands in the center while the others slide the ring secretly from hand to hand along the string. The central player must deduce who is currently holding the hidden ring.'; Materials='A piece of string and a small metal ring or button.'; Cultural='A traditional game prioritizing observation and sleight of hand, frequently played during rainy afternoons or quiet family evenings when outdoor movement was limited.' },
    @{ Title='Ring-a-Roses (Jamaican Variant)'; Slug='ring-a-roses'; Category='ring'; CatLabel='Ring Games'; Icon='fa-circle'; Desc='An adapted version of the traditional British nursery rhyme.'; FullDesc='An adapted version of the traditional British nursery rhyme. Children hold hands, skip rapidly in a clockwise circle while singing, and completely collapse to the ground in a laughing heap on the final synchronized cue.'; Materials='None.'; Cultural='Demonstrates the systematic re-harmonization of British colonial nursery rhymes with distinct Jamaican patois inflections and rhythms.' },
    @{ Title='S-T-O-P'; Slug='s-t-o-p'; Category='ring'; CatLabel='Ring Games'; Icon='fa-hand-back-fist'; Desc='A high-tension rhythmic elimination game.'; FullDesc='A high-tension rhythmic elimination game. Children sit or stand in a circle with palms facing up, overlapping each other''s hands. As they chant and spell out "S-T-O-P," a traveling slap passes sequentially from hand to hand. The player targeted on the final letter "P" must withdraw their hand before it is slapped; failing to do so results in elimination.'; Materials='None.'; Cultural='Fosters intense cognitive focus, group rhythm, and sudden response timing.' },
    @{ Title='Sack Race'; Slug='sack-race'; Category='field-day'; CatLabel='Field Day Games'; Icon='fa-box'; Desc='A high-energy jumping race.'; FullDesc='A high-energy jumping race. Competitors step inside large, heavy crocus bags (burlap sacks) that reach up to their waists, holding the edges up with their hands. At the signal, they must hop forward like rabbits toward the finish line. Falling over is common, making it a highly entertaining spectator event.'; Materials='Discarded burlap crocus sacks (originally used for transporting coffee beans, sugar, or flour).'; Cultural='Utilized the heavy-duty packaging material of Jamaica''s agricultural industries, turning industrial waste into a test of leg strength and endurance.' },
    @{ Title='Salad-a-Kick'; Slug='salad-a-kick'; Category='yard'; CatLabel='Yard Games'; Icon='fa-futbol'; Desc='A high-stakes kicking and passing game.'; FullDesc='A high-stakes kicking and passing game. A group of players kicks a tennis ball around a circle. If a player allows the ball to be kicked directly between their wide-open legs (a "salad"), they are subjected to lighthearted, playful kicks or chases from the rest of the group until they reach a safe zone.'; Materials='A tennis ball or plastic ball.'; Cultural='A rough-and-tumble street game emphasizing defensive footwork, leg coordination, and thick-skinned humor.' },
    @{ Title='Sen Mi Niki Go A Skuul'; Slug='sen-mi-niki-go-a-skuul'; Category='ring'; CatLabel='Ring Games'; Icon='fa-school'; Desc='A lively, instructional ring game.'; FullDesc='A lively, instructional ring game. Children form a circle while singing a call-and-response song about sending a child named Nicky to school. The person in the center must perform specific, synchronized dance moves---such as the classic Jamaican "wainin" (whining) waistline movement---on command, before tagging the next dancer.'; Materials='None.'; Cultural='A vibrant example of Afro-Jamaican oral tradition preserved by the Jamaica Cultural Development Commission (JCDC), emphasizing dance as a medium for socialization and identity.' },
    @{ Title='Shadow Puppets'; Slug='shadow-puppets'; Category='night'; CatLabel='Night Games'; Icon='fa-hand-sparkles'; Desc='Under the bright light of a full moon or a kerosene lantern outdoors, children use intricate hand contortions to cast shadows of barking…'; FullDesc='Under the bright light of a full moon or a kerosene lantern outdoors, children use intricate hand contortions to cast shadows of barking dogs, flying birds, and folklore characters against the walls of wooden houses.'; Materials='A light source (moonlight, flashlight, or lantern) and a flat wall.'; Cultural='Served as an interactive visual aid for grandparents and elders sharing traditional Anansi stories and West African folktales at night.' },
    @{ Title='Shadow Tag'; Slug='shadow-tag'; Category='yard'; CatLabel='Yard Games'; Icon='fa-sun'; Desc='A creative outdoor variation of tag played on bright, sunny days.'; FullDesc='A creative outdoor variation of tag played on bright, sunny days. Instead of touching a player''s physical body, the tagger must run and step directly onto the silhouette of an opponent''s shadow on the ground.'; Materials='Bright sunlight.'; Cultural='Required players to be highly aware of their environment, the position of the sun, and body angles to manipulate and hide their shadows.' },
    @{ Title='Shoe Box Theater'; Slug='shoe-box-theater'; Category='craft'; CatLabel='Creative Crafts'; Icon='fa-tv'; Desc='A wonderful indoor creative toy.'; FullDesc='A wonderful indoor creative toy. Children cut a small circular "peep hole" into one short end of a cardboard shoebox and a large square window in the lid, covered with translucent colored cellophane. Inside the box, they arrange miniature landscapes made of twigs, paper cut-out characters, and colorful foil. Looking through the peep hole reveals a brightly illuminated, theatrical 3D scene.'; Materials='A shoe box, scissors, colored paper, scraps of foil, glue, and cellophane.'; Cultural='A popular domestic craft that allowed children to become visual storytellers, creating their own self-contained diorama theaters to illustrate school lessons or bedtime stories.' },
    @{ Title='Skip Rope'; Slug='skip-rope'; Category='jump'; CatLabel='Jump & Skip'; Icon='fa-grip-lines'; Desc='The classic jump rope game, solo or with a crew turning the rope.'; FullDesc='The classic jump rope game, solo or with a crew turning the rope.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Skip Rope turned rhythm and footwork into a competition every child wanted to win — and every big sister was unbeatable at.' },
    @{ Title='Sling Shot (Bingy)'; Slug='sling-shot-bingy'; Category='homemade'; CatLabel='Homemade Toys'; Icon='fa-crosshairs'; Desc='A forked-stick slingshot for aiming and launching with precision.'; FullDesc='A forked-stick slingshot for aiming and launching with precision.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Sling Shot (Bingy) is a small monument to "tun yuh han'' mek fashion" — turning whatever was lying around the yard into something worth building, showing off, and passing on.' },
    @{ Title='Stilts'; Slug='stilts'; Category='homemade'; CatLabel='Homemade Toys'; Icon='fa-person-walking'; Desc='Wooden stilts for walking tall and balancing.'; FullDesc='Wooden stilts for walking tall and balancing.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Stilts is a small monument to "tun yuh han'' mek fashion" — turning whatever was lying around the yard into something worth building, showing off, and passing on.' },
    @{ Title='Stink-Up'; Slug='stink-up'; Category='yard'; CatLabel='Yard Games'; Icon='fa-face-dizzy'; Desc='A high-speed street game combining elements of tag and hide-and-seek.'; FullDesc='A high-speed street game combining elements of tag and hide-and-seek. The seeker closes their eyes at a base and shouts a traditional warning rhyme. The other players scatter into nearby lanes. If the seeker spots a player and calls out their name and exact hiding spot, that player becomes "stunk up" and must chase the remaining hidden players to pass on the penalty. - **Chant:** "Stink-up, stink-up, smell a rotten egg! Last one to the base is a rotten egg!"'; Materials='None.'; Cultural='A high-energy neighborhood game common in both urban tenement yards and rural villages, fostering lightning-fast running reflexes and stealth under pressure.' },
    @{ Title='Stuckie (Stucky Ketchy)'; Slug='stuckie-stucky-ketchy'; Category='yard'; CatLabel='Yard Games'; Icon='fa-hand'; Desc='The Jamaican version of traditional tag.'; FullDesc='The Jamaican version of traditional tag. One player is designated as "It" and tries to chase and touch other players. Once tagged, a player must immediately freeze in place, completely immobilized ("stuck"), until a free teammate tags them to restore mobility.'; Materials='None (requires an open space).'; Cultural='Playfully highlights the concepts of collective survival and mutual aid, values heavily emphasized in post-emancipation communal village life across Jamaica.' },
    @{ Title='Stucky Freezy'; Slug='stucky-freezy'; Category='yard'; CatLabel='Yard Games'; Icon='fa-snowflake'; Desc='Freeze and unfreeze — a game of quick reactions.'; FullDesc='Freeze and unfreeze — a game of quick reactions.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Like most Jamaican yard games, Stucky Freezy needed no referee, no equipment budget, and no adult supervision — just an open patch of dirt and whoever showed up that afternoon.' },
    @{ Title='Stucky Pully (Chain Tag)'; Slug='stucky-pully'; Category='yard'; CatLabel='Yard Games'; Icon='fa-link'; Desc='A collaborative variation of tag.'; FullDesc='A collaborative variation of tag. The game begins with one player who is "It." When they tag another player, instead of that player freezing, they must link hands with the tagger. They now move together as a growing chain ("pully"), trying to trap and tag the remaining free players with their free outer hands.'; Materials='None (requires an open field or yard).'; Cultural='Celebrated for building strategic group coordination, this game mirrors the cooperative nature of community security and collective mobilization in early rural settlements.' },
    @{ Title='Taw (Spawns)'; Slug='taw'; Category='yard'; CatLabel='Yard Games'; Icon='fa-bullseye'; Desc='A precision targeting game played in dirt fields.'; FullDesc='A precision targeting game played in dirt fields. Players throw large, heavy stones from a distance to strike, displace, or shatter an opponent''s fixed target stone to win points.'; Materials='Smooth river rocks or heavy construction stones.'; Cultural='Developed throwing precision, distance calculation, and spatial judgment among young boys in rural agricultural communities.' },
    @{ Title='The Farmer Run Away'; Slug='farmer-run-away'; Category='ring'; CatLabel='Ring Games'; Icon='fa-tractor'; Desc='A progressive role-playing ring game.'; FullDesc='A progressive role-playing ring game. A "farmer" is chosen in the center, who sequentially chooses a "wife," a "child," a "nurse," and pets. The game takes a unique Jamaican turn as the entire line breaks out into an erratic, zigzagging chase across the yard to an upbeat cadence.'; Materials='None.'; Cultural='Features structural changes from European folk templates, leaning heavily into high-tempo, outdoor theatrical tracking and chasing.' },
    @{ Title='Thread the Needle'; Slug='thread-the-needle'; Category='ring'; CatLabel='Ring Games'; Icon='fa-link'; Desc='A fast-moving, cooperative line game.'; FullDesc='A fast-moving, cooperative line game. Children form a long chain by holding hands. The first two players raise their arms to form an arch ("the eye of the needle"). The rest of the line, led by the player at the opposite end, must run through the arch in a continuous, winding thread without breaking their grip.'; Materials='None.'; Cultural='A traditional ring and line game that fostered group cohesion, rhythm, and agility in rural school yards.' },
    @{ Title='Three-Legged Race'; Slug='three-legged-race'; Category='field-day'; CatLabel='Field Day Games'; Icon='fa-shoe-prints'; Desc='A high-coordination teamwork race.'; FullDesc='A high-coordination teamwork race. Partners stand side-by-side, and their inside legs are tied securely together at the ankle using a piece of cloth or rope, effectively giving them three legs instead of four. They must synchronize their strides perfectly to run toward a finish line without tripping over one another.'; Materials='Strips of cloth, rags, or soft rope.'; Cultural='A staple of emancipation celebrations and community fairs, emphasizing synchronization, communication, and mutual reliance between peers.' },
    @{ Title='Tin Can Stilts'; Slug='tin-can-stilts'; Category='homemade'; CatLabel='Homemade Toys'; Icon='fa-shoe-prints'; Desc='A beginner-friendly variation of bamboo stilts.'; FullDesc='A beginner-friendly variation of bamboo stilts. Two empty, sturdy tin cans are cleaned out. They are turned upside down so the solid metal base faces up. Two small holes are punched through the sides near the top, and a long loop of string is threaded through. Children stand on the cans, pulling upward on the strings to keep the cans flat against their feet as they walk.'; Materials='Two sturdy tin cans (like condensed milk or juice cans) and strong twine.'; Cultural='Provided younger children with a safer, low-to-the-ground introduction to balance and stilt-walking engineering before graduated to tall bamboo poles.' },
    @{ Title='Twi Twi Twi'; Slug='twi-twi-twi'; Category='ring'; CatLabel='Ring Games'; Icon='fa-dove'; Desc='An advanced coordination game requiring flawless hand-clapping and foot-tapping synchronicity.'; FullDesc='An advanced coordination game requiring flawless hand-clapping and foot-tapping synchronicity. Partners stand face-to-face or in clusters, accelerating their clapping patterns to a song about a bird, testing focus and speed.'; Materials='None.'; Cultural='Directly displays African cultural retention, as "Twi" is a principal dialect of the Akan people of Ghana, from whom many Jamaicans descend.' },
    @{ Title='Wire Car'; Slug='wire-car'; Category='homemade'; CatLabel='Homemade Toys'; Icon='fa-car'; Desc='A handmade car crafted from wire and imagination.'; FullDesc='A handmade car crafted from wire and imagination.'; Materials='Materials list coming soon — help us fill this in!'; Cultural='Wire Car is a small monument to "tun yuh han'' mek fashion" — turning whatever was lying around the yard into something worth building, showing off, and passing on.' },
    @{ Title='Zaki Yik and Ben'; Slug='zaki-yik-and-ben'; Category='ring'; CatLabel='Ring Games'; Icon='fa-shoe-prints'; Desc='A fast-paced, highly rhythmic counting and stepping ring game where children drop their feet in and out of the circle center to match a…'; FullDesc='A fast-paced, highly rhythmic counting and stepping ring game where children drop their feet in and out of the circle center to match a complex, syncopated vocal rhythm.'; Materials='None.'; Cultural='Preserves ancestral West African dance spacing and polyrhythmic stepping patterns within rural schools.' }
)
# ============================================================
# 3b. IMAGE FILENAME OVERRIDES
#     Real photo files don't always match the slug naming
#     convention (e.g. "marble.png" instead of "marbles.jpg").
#     Add an entry here whenever a real file's name differs from
#     "<slug>.jpg". Anything NOT listed here falls back to
#     "<slug>.jpg" and shows the "Photo Coming Soon" placeholder
#     until that file actually exists.
# ============================================================
$imageOverrides = @{
    'dominoes'      = 'dominoes.png'
    'gig-building'  = 'gig.png'
    'hose-hoop-wheel' = 'hose-wheel.png'
    'ludi'          = 'ludo.jpg'
    'marbles'       = 'marble.png'
    'bearing-skate' = 'skate.png'
    'elder-storytelling' = 'story.png'
    'stucky-freezy' = 'stucky.png'
}

# ============================================================
# 4. SHARED "SHARE YOUR STORY" CALL-TO-ACTION BLOCK
#    (injected into every detail page + the index page)
# ============================================================
function Get-SubmitBlock {
    param([string]$GameTitle, [string]$Email, [string]$InstaTag)

    $subject = [uri]::EscapeDataString("My $GameTitle story")
    $mailto  = "mailto:$Email?subject=$subject"

    return @"
<section class="submit-cta">
  <div class="submit-cta-inner">
    <div class="submit-cta-icon"><i class="fas fa-heart"></i></div>
    <h2>Did You Play $GameTitle?</h2>
    <p>Wherever you grew up — Kingston, Montego Bay, Brooklyn, Toronto, London, Miami —
       if you remember playing this, we want to hear from you. Send us your story,
       your photos, or an old video. Every submission helps preserve this game for
       the next generation.</p>
    <div class="submit-cta-actions">
      <a href="$mailto" class="btn-submit primary"><i class="fas fa-envelope"></i> Email Your Story</a>
      <a href="https://instagram.com/selassiefest" target="_blank" rel="noopener noreferrer" class="btn-submit"><i class="fab fa-instagram"></i> Tag Us: $InstaTag</a>
    </div>
    <p class="submit-cta-note">Photos and stories may be featured on this page and across our social channels (with credit to you).</p>
  </div>
</section>
"@
}

# ============================================================
# 5. SHARED PAGE HEAD/CSS (used by index + every detail page)
# ============================================================
$sharedStyle = @'
<style>
    :root {
      --black: #090909; --roots-green: #0F6A3A; --gold: #F3C13A; --heritage-red: #C92828;
      --cream: #F8F4EA; --text-white: #F5F5F5; --card-bg: rgba(255,255,255,0.04);
      --border-dim: rgba(255,255,255,0.08); --transition-default: all 0.3s ease;
      --font-heading: 'Fredoka', sans-serif; --font-accent: 'Bebas Neue', sans-serif; --font-body: 'Inter', sans-serif;
    }
    * { margin:0; padding:0; box-sizing:border-box; }
    html { scroll-behavior:smooth; -webkit-font-smoothing:antialiased; }
    body { background-color:var(--black); color:var(--text-white); font-family:var(--font-body); line-height:1.6; }
    a { text-decoration:none; color:inherit; transition:var(--transition-default); }
    .container { max-width:1100px; margin:0 auto; padding:0 24px; }
    .site-header { padding:18px 24px; border-bottom:1px solid var(--border-dim); background:rgba(9,9,9,0.96); position:sticky; top:0; z-index:1000; }
    .header-flex { display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px; max-width:1300px; margin:0 auto; }
    .brand-link { display:flex; flex-direction:column; }
    .site-title { font-family:var(--font-accent); font-size:1.3rem; letter-spacing:0.08em; color:var(--cream); }
    .tagline { font-family:var(--font-body); font-weight:300; font-size:0.55rem; text-transform:uppercase; letter-spacing:0.12em; color:var(--gold); opacity:0.85; }
    .pt-nav { background:rgba(15,106,58,0.08); border-bottom:1px solid var(--border-dim); position:sticky; top:65px; z-index:999; backdrop-filter: blur(6px); }
    .pt-nav-container { max-width:1300px; margin:0 auto; padding:0.8rem 24px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; }
    .pt-logo { display:flex; align-items:center; gap:8px; font-family:var(--font-heading); font-weight:500; font-size:1.1rem; color:var(--cream); }
    .pt-logo i { color:var(--gold); }
    .pt-nav-links { display:flex; gap:1.4rem; flex-wrap:wrap; }
    .pt-nav-links a { font-size:0.85rem; text-transform:uppercase; letter-spacing:0.04em; color:#ddd; border-bottom:2px solid transparent; padding-bottom:3px; }
    .pt-nav-links a:hover, .pt-nav-links a.active { color:var(--gold); border-bottom-color:var(--gold); }
    .game-hero { text-align:center; padding:3.5rem 1.5rem 2.5rem; border-bottom:1px solid var(--border-dim);
      background: radial-gradient(ellipse at 30% 20%, rgba(15,106,58,0.18), transparent 60%), radial-gradient(ellipse at 80% 80%, rgba(201,40,40,0.12), transparent 55%); }
    .game-hero .cat-badge { display:inline-block; background:rgba(243,193,58,0.12); border:1px solid rgba(243,193,58,0.4); color:var(--gold); font-size:0.75rem; text-transform:uppercase; letter-spacing:0.08em; padding:0.4rem 1.1rem; border-radius:30px; margin-bottom:1.2rem; }
    .game-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.8rem; margin-bottom:0.6rem; }
    .game-hero p.tagline-desc { color:#ccc; font-size:1.1rem; max-width:640px; margin:0 auto; font-weight:300; }
    .photo-placeholder { width:100%; aspect-ratio:16/9; border:2px dashed rgba(243,193,58,0.35); border-radius:20px; background:rgba(255,255,255,0.02);
      display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px; color:rgba(245,245,245,0.4); font-size:0.8rem; text-align:center; padding:16px; margin: 2rem 0; }
    .photo-placeholder i { font-size:2rem; color:rgba(243,193,58,0.45); }
    .photo-placeholder .ph-label { font-weight:600; letter-spacing:0.05em; text-transform:uppercase; font-size:0.72rem; }
    .game-body { padding:3rem 0; }
    .info-strip { display:flex; flex-wrap:wrap; gap:14px; margin-bottom:2.2rem; }
    .info-chip { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:16px; padding:12px 18px; flex:1; min-width:200px; }
    .info-chip .label { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.06em; color:var(--gold); margin-bottom:4px; }
    .info-chip .value { font-size:0.95rem; font-weight:300; }
    .game-section-title { font-family:var(--font-heading); font-weight:500; font-size:1.4rem; color:var(--cream); margin: 2rem 0 1rem; display:flex; align-items:center; gap:10px; }
    .game-section-title i { color:var(--roots-green); }
    .cultural-note { background:rgba(201,40,40,0.06); border-left:4px solid var(--heritage-red); border-radius:12px; padding:18px 22px; font-weight:300; font-style:italic; color:#ddd; margin-top:1rem; }
    .back-link { display:inline-flex; align-items:center; gap:8px; color:var(--gold); font-weight:500; margin-top:2.5rem; }
    .hub-hero { text-align:center; padding:3.5rem 1.5rem 2rem; }
    .hub-hero h1 { font-family:var(--font-heading); font-weight:600; font-size:2.6rem; margin-bottom:0.8rem; }
    .hub-hero p { color:#bbb; max-width:680px; margin:0 auto; font-weight:300; }
    .archive-controls { display:flex; flex-wrap:wrap; gap:12px; align-items:center; justify-content:center; margin: 2rem 0; }
    .filter-btn { background:var(--card-bg); border:1px solid var(--border-dim); color:#ccc; padding:8px 18px; border-radius:30px; font-size:0.82rem; cursor:pointer; text-transform:uppercase; letter-spacing:0.04em; }
    .filter-btn.active, .filter-btn:hover { background:var(--gold); color:#0a0a0a; border-color:var(--gold); }
    .game-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:1.3rem; padding-bottom:3rem; }
    .game-card { background:var(--card-bg); border:1px solid var(--border-dim); border-radius:1.1rem; padding:0; overflow:hidden; transition:var(--transition-default); display:flex; flex-direction:column; }
    .game-card:hover { border-color:var(--gold); transform:translateY(-3px); }
    .card-img-wrap { position:relative; width:100%; aspect-ratio:4/3; background:rgba(255,255,255,0.03); overflow:hidden; }
    .card-img-wrap img { width:100%; height:100%; object-fit:cover; display:block; }
    .card-img-placeholder { position:absolute; inset:0; display:none; flex-direction:column; align-items:center; justify-content:center; gap:6px; background:rgba(255,255,255,0.02); color:rgba(245,245,245,0.35); text-align:center; padding:10px; }
    .card-img-placeholder i { font-size:1.4rem; color:rgba(243,193,58,0.4); }
    .card-img-placeholder span { font-size:0.62rem; text-transform:uppercase; letter-spacing:0.05em; font-weight:600; }
    .card-body { padding:1.3rem 1.5rem 1.5rem; display:flex; flex-direction:column; flex:1; }
    .game-card .icon { font-size:1.3rem; color:var(--gold); margin-bottom:0.6rem; }
    .game-card h3 { font-family:var(--font-heading); font-weight:500; font-size:1.15rem; margin-bottom:0.5rem; }
    .game-card p { color:#aaa; font-size:0.88rem; flex:1; margin-bottom:1rem; font-weight:300; }
    .game-card .cat-tag { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.05em; color: var(--roots-green); margin-bottom:0.6rem; }
    .game-card a.btn-sm { color:var(--gold); font-size:0.82rem; font-weight:600; text-transform:uppercase; }
    footer.site-footer { text-align:center; padding:2.5rem 1.5rem; border-top:1px solid var(--border-dim); color:#777; font-size:0.85rem; }
    .footer-social { display:flex; justify-content:center; gap:18px; margin-bottom:1.2rem; }
    .footer-social a { width:40px; height:40px; border-radius:50%; border:1px solid var(--border-dim); display:flex; align-items:center; justify-content:center; color:#ccc; font-size:1.1rem; background:rgba(255,255,255,0.03); }
    .footer-social a:hover { border-color:var(--gold); color:var(--gold); background:rgba(243,193,58,0.08); }
    .footer-contact { margin-bottom:0.8rem; font-size:0.8rem; color:#999; }
    .footer-contact a { color:#999; }
    .footer-contact a:hover { color:var(--gold); }
    .footer-contact .sep { margin:0 8px; color:#555; }
    .submit-banner { background:linear-gradient(135deg, rgba(15,106,58,0.16), rgba(201,40,40,0.12)); border:1px solid rgba(243,193,58,0.3); border-radius:24px; padding:2.4rem 2rem; margin:2.5rem 0; text-align:center; }
    .submit-banner h2 { font-family:var(--font-heading); font-size:1.9rem; margin-bottom:0.7rem; }
    .submit-banner p { color:#ddd; font-weight:300; max-width:680px; margin:0 auto 1.4rem; }
    .submit-banner .submit-cta-actions { display:flex; flex-wrap:wrap; gap:12px; justify-content:center; }
    .submit-cta { background:rgba(255,255,255,0.03); border:1px solid rgba(243,193,58,0.25); border-radius:24px; padding:2.4rem 2rem; margin:3rem 0 1rem; text-align:center; }
    .submit-cta-icon { font-size:1.8rem; color:var(--heritage-red); margin-bottom:0.8rem; }
    .submit-cta h2 { font-family:var(--font-heading); font-size:1.6rem; margin-bottom:0.8rem; }
    .submit-cta p { color:#ccc; font-weight:300; max-width:600px; margin:0 auto 1.2rem; font-size:0.95rem; }
    .submit-cta-actions { display:flex; flex-wrap:wrap; gap:12px; justify-content:center; margin-bottom:1rem; }
    .btn-submit { display:inline-flex; align-items:center; gap:8px; padding:12px 24px; border-radius:40px; font-size:0.85rem; font-weight:600; text-transform:uppercase; letter-spacing:0.04em; border:1px solid var(--gold); color:var(--gold); background:transparent; }
    .btn-submit.primary { background:var(--gold); color:#0a0a0a; }
    .btn-submit:hover { opacity:0.85; }
    .submit-cta-note { font-size:0.75rem; color:#888; font-style:italic; }
    @media (max-width:700px) {
      .game-hero h1, .hub-hero h1 { font-size:1.9rem; }
      .header-flex { justify-content:center; text-align:center; }
    }
</style>
'@

$sharedHead = @'
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@400;500;600;700&family=Inter:wght@300;400;500;600&family=Bebas+Neue&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
'@

$sharedHeader = @'
<header class="site-header">
  <div class="header-flex">
    <a href="/" class="brand-link">
      <div class="site-title">SELASSIEFEST</div>
      <div class="tagline">One Day. One Love. One Society.</div>
    </a>
  </div>
</header>
'@

# ============================================================
# 6. DETAIL-PAGE TEMPLATE (tokens replaced per game below)
# ============================================================
$detailTemplate = @'
<!DOCTYPE html>
<html lang="en">
<head>
{{HEAD}}
<title>{{TITLE}} | Pickney Time Games Archive</title>
<meta name="description" content="How to play {{TITLE}}, a traditional Jamaican game — plus share your own photos and memories.">
{{STYLE}}
</head>
<body>
{{HEADER}}
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/calendar/games/" class="active">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="game-hero">
  <span class="cat-badge">{{CATLABEL}}</span>
  <h1>{{TITLE}}</h1>
  <p class="tagline-desc">{{DESC}}</p>
</div>

<div class="container game-body">
  <div class="photo-placeholder">
    <i class="fas fa-camera"></i>
    <span class="ph-label">Photo Wanted</span>
    <span>Be the first to send a real photo of {{TITLE}} being played.</span>
  </div>

  <div class="info-strip">
    <div class="info-chip">
      <div class="label">Category</div>
      <div class="value">{{CATLABEL}}</div>
    </div>
    <div class="info-chip">
      <div class="label">Materials</div>
      <div class="value">{{MATERIALS}}</div>
    </div>
  </div>

  <h2 class="game-section-title"><i class="fas fa-circle-info"></i> How It's Played</h2>
  <p style="font-weight:300; color:#ddd;">{{FULLDESC}}</p>

  <h2 class="game-section-title"><i class="fas fa-landmark"></i> Cultural Roots</h2>
  <div class="cultural-note">{{CULTURAL}}</div>

  {{SUBMITBLOCK}}

  <a href="/calendar/games/" class="back-link"><i class="fas fa-arrow-left"></i> Back to Games Archive</a>
</div>

<footer class="site-footer">
  <div class="footer-social">
    {{FOOTERSOCIAL}}
  </div>
  <div class="footer-contact">
    <a href="mailto:{{CONTACTEMAIL}}">{{CONTACTEMAIL}}</a><span class="sep">&middot;</span><a href="tel:{{CONTACTPHONE}}">{{CONTACTPHONEDISPLAY}}</a>
  </div>
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>
'@

# ============================================================
# 7. BUILD ALL 107 DETAIL PAGES
# ============================================================
$submitEmailBlockGeneric = Get-SubmitBlock -GameTitle "This Game" -Email $SubmitEmail -InstaTag $InstagramTag

foreach ($g in $games) {
    $submitBlock = Get-SubmitBlock -GameTitle $g.Title -Email $SubmitEmail -InstaTag $InstagramTag
    $page = $detailTemplate `
        -replace '\{\{HEAD\}\}', $sharedHead `
        -replace '\{\{STYLE\}\}', $sharedStyle `
        -replace '\{\{HEADER\}\}', $sharedHeader `
        -replace '\{\{TITLE\}\}', $g.Title `
        -replace '\{\{CATLABEL\}\}', $g.CatLabel `
        -replace '\{\{DESC\}\}', $g.Desc `
        -replace '\{\{FULLDESC\}\}', $g.FullDesc `
        -replace '\{\{MATERIALS\}\}', $g.Materials `
        -replace '\{\{CULTURAL\}\}', $g.Cultural `
        -replace '\{\{SUBMITBLOCK\}\}', $submitBlock `
        -replace '\{\{FOOTERSOCIAL\}\}', $footerSocialHtml `
        -replace '\{\{CONTACTEMAIL\}\}', $SubmitEmail `
        -replace '\{\{CONTACTPHONE\}\}', $ContactPhone `
        -replace '\{\{CONTACTPHONEDISPLAY\}\}', $ContactPhone
    $outPath = Join-Path $gamesDir "$($g.Slug).html"
    Set-Content -Path $outPath -Value $page -Encoding UTF8
}
Write-Host "Wrote $($games.Count) detail pages." -ForegroundColor Green

# ============================================================
# 8. BUILD index.html
# ============================================================
$filterButtons = "<button class=`"filter-btn active`" data-filter=`"all`">All</button>`n"
foreach ($c in $categories) {
    $filterButtons += "    <button class=`"filter-btn`" data-filter=`"$($c.Key)`">$($c.Label)</button>`n"
}

$cardsHtml = ""
foreach ($g in ($games | Sort-Object Title)) {
    $imgFile = if ($imageOverrides.ContainsKey($g.Slug)) { $imageOverrides[$g.Slug] } else { "$($g.Slug).jpg" }
    $cardsHtml += @"
  <div class="game-card" data-category="$($g.Category)">
    <div class="card-img-wrap">
      <img src="/calendar/games/images/$imgFile" alt="$($g.Title) — traditional Jamaican game" loading="lazy" onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
      <div class="card-img-placeholder"><i class="fas fa-camera"></i><span>Photo Coming Soon</span></div>
    </div>
    <div class="card-body">
      <div class="cat-tag">$($g.CatLabel)</div>
      <div class="icon"><i class="fas $($g.Icon)"></i></div>
      <h3>$($g.Title)</h3>
      <p>$($g.Desc)</p>
      <a href="/calendar/games/$($g.Slug).html" class="btn-sm">Learn More <i class="fas fa-arrow-right"></i></a>
    </div>
  </div>
"@
}

$indexSubmitSubject = [uri]::EscapeDataString("My Jamaican Game Story")
$indexMailto = "mailto:$SubmitEmail?subject=$indexSubmitSubject"

$indexTemplate = @'
<!DOCTYPE html>
<html lang="en">
<head>
{{HEAD}}
<title>Games Archive | Pickney Time Games Archive</title>
<meta name="description" content="107 traditional Jamaican childhood games and homemade toys, documented with help from the global Jamaican diaspora.">
{{STYLE}}
</head>
<body>
{{HEADER}}
<div class="pt-nav">
  <div class="pt-nav-container">
    <div class="pt-logo"><i class="fas fa-child"></i><span>Pickney Time</span></div>
    <div class="pt-nav-links">
      <a href="/pickney-time/">Event Home</a>
      <a href="/calendar/games/" class="active">Games Archive</a>
      <a href="/pickney-time/#register">Register</a>
    </div>
  </div>
</div>

<div class="hub-hero">
  <h1>Pickney Time Games Archive</h1>
  <p>107 traditional Jamaican childhood games, toys, and stories — and growing. This archive is being built with the Jamaican community worldwide. Recognize one from your own childhood? Tell us about it.</p>
</div>

<div class="container">
  <section class="submit-banner">
    <h2>Help Us Build the World's Largest Jamaican Games Archive</h2>
    <p>Wherever you grew up playing these games — Jamaica, the UK, the US, Canada, or anywhere else the diaspora calls home —
       we want your photos, videos, and memories. Every story you send helps keep these games alive for the next generation.</p>
    <div class="submit-cta-actions">
      <a href="{{MAILTO}}" class="btn-submit primary"><i class="fas fa-envelope"></i> Email Your Story</a>
      <a href="https://instagram.com/selassiefest" target="_blank" rel="noopener noreferrer" class="btn-submit"><i class="fab fa-instagram"></i> Tag {{INSTATAG}}</a>
    </div>
  </section>

  <div class="archive-controls" id="filterGroup">
    {{FILTERS}}
  </div>
  <div class="game-grid" id="gameGrid">
{{CARDS}}
  </div>
</div>
<script>
document.querySelectorAll('.filter-btn').forEach(btn => {
  btn.addEventListener('click', function() {
    document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
    this.classList.add('active');
    const filter = this.dataset.filter;
    document.querySelectorAll('.game-card').forEach(card => {
      card.style.display = (filter === 'all' || card.dataset.category === filter) ? 'flex' : 'none';
    });
  });
});
</script>

<footer class="site-footer">
  <div class="footer-social">
    {{FOOTERSOCIAL}}
  </div>
  <div class="footer-contact">
    <a href="mailto:{{CONTACTEMAIL}}">{{CONTACTEMAIL}}</a><span class="sep">&middot;</span><a href="tel:{{CONTACTPHONE}}">{{CONTACTPHONEDISPLAY}}</a>
  </div>
  &copy; 2026 Ras Tafari Inc. &middot; Pickney Time &middot; <a href="/pickney-time/" style="color:var(--gold);">Back to Event Page</a>
</footer>
</body>
</html>
'@

$indexHtml = $indexTemplate `
    -replace '\{\{HEAD\}\}', $sharedHead `
    -replace '\{\{STYLE\}\}', $sharedStyle `
    -replace '\{\{HEADER\}\}', $sharedHeader `
    -replace '\{\{FILTERS\}\}', $filterButtons `
    -replace '\{\{CARDS\}\}', $cardsHtml `
    -replace '\{\{MAILTO\}\}', $indexMailto `
    -replace '\{\{INSTATAG\}\}', $InstagramTag `
    -replace '\{\{FOOTERSOCIAL\}\}', $footerSocialHtml `
    -replace '\{\{CONTACTEMAIL\}\}', $SubmitEmail `
    -replace '\{\{CONTACTPHONE\}\}', $ContactPhone `
    -replace '\{\{CONTACTPHONEDISPLAY\}\}', $ContactPhone
Set-Content -Path (Join-Path $gamesDir "index.html") -Value $indexHtml -Encoding UTF8
Write-Host "Wrote index.html with $($games.Count) games." -ForegroundColor Green
Write-Host ""
Write-Host "DONE. Site rebuilt at: $gamesDir" -ForegroundColor Cyan
Write-Host "Contact info is set: $SubmitEmail / $ContactPhone / 7 social links." -ForegroundColor Green
