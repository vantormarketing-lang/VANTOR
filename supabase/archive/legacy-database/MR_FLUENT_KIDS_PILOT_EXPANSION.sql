-- Mr. Fluent Kids pilot expansion: finish the first sample level in each track.
-- K0 = pre-reading sound awareness; P12 = Primary 1-2 school English support.
-- All new units and lessons remain unpublished until reviewed by staff.
-- Safe to re-run: published curriculum content is never overwritten.

insert into public.mrfluent_kids_units (level_id,title,description,sort_order,is_published)
select l.id,v.title,v.description,v.sort_order,false
from (values
 ('K0',2,'Unit 2: Words Have Beats','Listen for syllables, count sound beats and notice endings.'),
 ('K0',3,'Unit 3: Sound Matchers','Compare beginning sounds and practise listening memory.'),
 ('K0',4,'Unit 4: Ready for ABC','Review listening, rhyming and sound-to-picture matching.'),
 ('P12',2,'Unit 2: Meet My Family','Learn family words and use have or has in simple sentences.'),
 ('P12',3,'Unit 3: Build a Sentence','Build simple sentences and choose the right punctuation.'),
 ('P12',4,'Unit 4: Mini Reading','Read a short text and find important details.')
) as v(level_code,sort_order,title,description)
join public.mrfluent_kids_levels l on l.code=v.level_code
on conflict (level_id,sort_order) do update
set title=excluded.title,description=excluded.description,updated_at=now()
where public.mrfluent_kids_units.is_published=false;

insert into public.mrfluent_kids_lessons
 (unit_id,title,objective,lesson_type,lesson_payload,sort_order,is_published)
select u.id,v.title,v.objective,v.lesson_type,v.lesson_payload,v.lesson_sort,false
from (values
 ('K0',2,1,'Clap the Syllables','Hear the beats in a spoken word.','learn',
  '{"intro":"Words can have one beat or more. Ask a grown-up to say each word slowly, then clap once for each beat.","steps":["Say sun and clap once.","Say apple and clap two times.","Say banana and clap three times."]}'::jsonb),
 ('K0',2,2,'Word with Two Beats','Choose the word with two spoken syllables.','game',
  '{"intro":"Listen carefully to each word. You can ask a grown-up to say the choices aloud.","question":"Which word has two beats?","options":[{"label":"sun","emoji":"☀️"},{"label":"banana","emoji":"🍌"},{"label":"cat","emoji":"🐱"}],"correct_index":1,"steps":["Listen to each word.","Clap the beats as you say it.","Pick the word with two beats."]}'::jsonb),
 ('K0',2,3,'Find the Final Sound','Listen for the sound at the end of a simple word.','game',
  '{"intro":"Words have sounds at the beginning and at the end. Say each word slowly with a grown-up.","question":"Which word ends with the /t/ sound?","options":[{"label":"cat","emoji":"🐱"},{"label":"cap","emoji":"🧢"},{"label":"can","emoji":"🥫"}],"correct_index":0,"steps":["Say the three words aloud.","Listen to the last sound.","Choose the word that ends with /t/."]}'::jsonb),
 ('K0',3,1,'Same or Different?','Compare the beginning sounds of two words.','game',
  '{"intro":"Two words can begin with the same sound. Listen to sun and sock.","question":"Do sun and sock begin with the same sound?","options":[{"label":"Same","emoji":"🤝"},{"label":"Different","emoji":"🔀"},{"label":"Not sure","emoji":"🤔"}],"correct_index":0,"steps":["Ask a grown-up to say both words.","Listen to their first sounds.","Choose same or different."]}'::jsonb),
 ('K0',3,2,'Sound Memory','Listen, remember and repeat sounds in the same order.','learn',
  '{"intro":"This is a listening-memory game. Ask a grown-up to say two short words or make two familiar sounds.","steps":["Listen without rushing.","Repeat the two sounds in the same order.","Try three sounds when two feel easy."]}'::jsonb),
 ('K0',3,3,'Sound Detective Mission','Notice sounds in your everyday world.','learn',
  '{"intro":"Become a sound detective with a trusted grown-up. You do not need to read any words for this mission.","steps":["Listen for a sound at home or outside with your grown-up.","Find one other thing that makes a similar sound.","Tell your grown-up what sounds alike."]}'::jsonb),
 ('K0',4,1,'Sound-to-Picture Match','Match a first sound to a familiar spoken word.','game',
  '{"intro":"Listen to the first sound of each choice. A grown-up can say the words aloud if you need help.","question":"Which word begins with the /m/ sound?","options":[{"label":"moon","emoji":"🌙"},{"label":"fish","emoji":"🐟"},{"label":"sun","emoji":"☀️"}],"correct_index":0,"steps":["Listen to the three words.","Say the first sound of each word.","Choose the word that begins with /m/."]}'::jsonb),
 ('K0',4,2,'Rhyming Review','Recognize words with matching ending sounds.','game',
  '{"intro":"Rhyming words have endings that sound alike. Say the words slowly before choosing.","question":"Which word rhymes with bee?","options":[{"label":"tree","emoji":"🌳"},{"label":"hat","emoji":"🎩"},{"label":"dog","emoji":"🐶"}],"correct_index":0,"steps":["Say bee, tree, hat and dog.","Listen to the ending sounds.","Choose the rhyming word."]}'::jsonb),
 ('K0',4,3,'Little Ears Challenge','Review syllables and sound awareness.','game',
  '{"intro":"You have practised listening, syllables and beginning sounds. Take this little review with a grown-up.","question":"Which word has three spoken beats?","options":[{"label":"banana","emoji":"🍌"},{"label":"apple","emoji":"🍎"},{"label":"cat","emoji":"🐱"}],"correct_index":0,"steps":["Say each word slowly.","Clap once for every beat.","Choose the word with three beats."]}'::jsonb),
 ('P12',2,1,'Family Word Pack','Recognize common family words in simple English.','learn',
  '{"intro":"Meet a family in English: mother, father, sister, brother, grandmother and grandfather.","steps":["Look at a family picture or draw a simple family tree with a grown-up.","Say each English word.","Use one word in a short sentence: This is my sister."]}'::jsonb),
 ('P12',2,2,'Have or Has?','Choose have or has in a simple present sentence.','game',
  '{"intro":"Use has with he, she or it. Use have with I, you, we or they.","question":"She ___ a blue bag.","options":[{"label":"have","emoji":"🎒"},{"label":"has","emoji":"✅"},{"label":"haves","emoji":"❌"}],"correct_index":1,"steps":["Read the whole sentence.","Notice the subject she.","Choose the verb that fits."]}'::jsonb),
 ('P12',2,3,'Who Is This?','Use family vocabulary to identify a relative.','game',
  '{"intro":"Family words help us describe people. Think about the family member in the question.","question":"My mother’s mother is my…","options":[{"label":"grandmother","emoji":"👵"},{"label":"cousin","emoji":"🧒"},{"label":"aunt","emoji":"👩"}],"correct_index":0,"steps":["Read the question carefully.","Think about the family relationship.","Choose the matching word."]}'::jsonb),
 ('P12',3,1,'I Am Ready','Practise am, is and are with simple subjects.','learn',
  '{"intro":"The verb be changes with the subject: I am, he or she is, and you or they are.","steps":["Read: I am ready.","Read: She is happy.","Read: They are friends.","Choose a subject and make your own sentence."]}'::jsonb),
 ('P12',3,2,'Build the Sentence','Recognize a correct simple English word order.','game',
  '{"intro":"A simple English sentence often begins with who, then an action, then the thing.","question":"Which sentence is correct?","options":[{"label":"I like books.","emoji":"📚"},{"label":"Like I books.","emoji":"🔀"},{"label":"I books like.","emoji":"🔀"}],"correct_index":0,"steps":["Read each sentence aloud.","Check the order of the words.","Choose the sentence that sounds correct."]}'::jsonb),
 ('P12',3,3,'Finish with a Mark','Choose punctuation that matches a question.','game',
  '{"intro":"A question asks something and ends with a question mark. A statement usually ends with a full stop.","question":"What mark ends a question?","options":[{"label":"!","emoji":"❗"},{"label":"?","emoji":"❓"},{"label":".","emoji":"🔵"}],"correct_index":1,"steps":["Read the prompt.","Think about which mark asks a question.","Choose the correct mark."]}'::jsonb),
 ('P12',4,1,'Read a Short Passage','Read a small text and understand its main details.','learn',
  '{"intro":"Read this short passage with care: Lina has a red bag. She likes books. She goes to school with Ali.","steps":["Read the passage once for the main idea.","Read it again and notice the people and objects.","Tell a grown-up two things you remember."]}'::jsonb),
 ('P12',4,2,'Find the Colour','Answer a detail question after reading a short passage.','game',
  '{"intro":"Remember the passage about Lina. Go back and read it again if you need to.","question":"What colour is Lina’s bag?","options":[{"label":"red","emoji":"🔴"},{"label":"green","emoji":"🟢"},{"label":"blue","emoji":"🔵"}],"correct_index":0,"steps":["Recall or reread the passage.","Find the word that describes the bag.","Choose the colour."]}'::jsonb),
 ('P12',4,3,'Find the Detail','Choose a detail that appears in the passage.','game',
  '{"intro":"The passage tells us what Lina likes. Read the words one more time if you need help.","question":"What does Lina like?","options":[{"label":"books","emoji":"📚"},{"label":"apples","emoji":"🍎"},{"label":"games","emoji":"🎲"}],"correct_index":0,"steps":["Read the passage about Lina.","Find the sentence about what she likes.","Choose the detail in the text."]}'::jsonb)
) as v(level_code,unit_sort,lesson_sort,title,objective,lesson_type,lesson_payload)
join public.mrfluent_kids_levels l on l.code=v.level_code
join public.mrfluent_kids_units u on u.level_id=l.id and u.sort_order=v.unit_sort
on conflict (unit_id,sort_order) do update
set title=excluded.title,objective=excluded.objective,lesson_type=excluded.lesson_type,
    lesson_payload=excluded.lesson_payload,updated_at=now()
where public.mrfluent_kids_lessons.is_published=false;
