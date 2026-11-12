-- Starter curriculum drafts for Mr. Fluent Kids.
-- These are deliberately unpublished. Review text/media and publish from Admin → Mr. Fluent Kids.
with levels as (
 select code,id from public.mrfluent_kids_levels where code in ('K0','P12')
), unit_data as (
 select v.level_code,v.sort_order,v.title,v.description,l.id as level_id
 from (values
  ('K0',1,'Unit 1: Little Sound Detectives','Listen, notice rhymes and find beginning sounds.'),
  ('P12',1,'Unit 1: My School Bag','Practise everyday school words and simple sentences.')
 ) v(level_code,sort_order,title,description)
 join levels l on l.code=v.level_code
), units_upsert as (
 insert into public.mrfluent_kids_units(level_id,title,description,sort_order,is_published)
 select level_id,title,description,sort_order,false from unit_data
 on conflict(level_id,sort_order) do update
 set title=excluded.title,description=excluded.description,updated_at=now()
 returning id,level_id,title
), lesson_data as (
 select u.id as unit_id,v.sort_order,v.title,v.objective,v.lesson_type,v.payload
 from units_upsert u
 join public.mrfluent_kids_levels lv on lv.id=u.level_id
 join (values
  ('K0',1,'Listen for Sounds','Notice sounds around you and tell whether two sounds match.','learn',jsonb_build_object('intro','Let’s be sound detectives! Listen closely and notice what you hear.','steps',jsonb_build_array('Listen to a familiar sound.','Say whether the two sounds match.','Try again and notice one detail.'))),
  ('K0',2,'Rhyming Friends','Hear words that have a similar ending sound.','game',jsonb_build_object('intro','Some words sound like friends because their endings rhyme.','question','Which word rhymes with cat?','options',jsonb_build_array(jsonb_build_object('label','hat','emoji','🎩'),jsonb_build_object('label','sun','emoji','☀️'),jsonb_build_object('label','dog','emoji','🐶')),'correct_index',0,'steps',jsonb_build_array('Say the words aloud.','Listen to their ending sounds.','Pick the words that rhyme.'))),
  ('K0',3,'First Sound Hunt','Notice the first sound in a simple spoken word.','game',jsonb_build_object('intro','Find the sound at the beginning of a word.','steps',jsonb_build_array('Hear the word slowly.','Say the first sound you hear.','Match that sound with a picture.'))),
  ('P12',1,'My School Bag','Name familiar school objects and match words to pictures.','learn',jsonb_build_object('intro','Let’s pack a school bag! Learn useful classroom words.','steps',jsonb_build_array('Look at a school object.','Say or read its English name.','Match the word to the picture.'))),
  ('P12',2,'A or An?','Choose a or an before familiar singular nouns.','game',jsonb_build_object('intro','Use “a” before a consonant sound and “an” before a vowel sound.','question','Which phrase is correct?','options',jsonb_build_array(jsonb_build_object('label','a apple','emoji','🍎'),jsonb_build_object('label','an apple','emoji','🍏'),jsonb_build_object('label','a banana','emoji','🍌')),'correct_index',1,'steps',jsonb_build_array('Read the word aloud.','Listen to its first sound.','Choose a or an.'))),
  ('P12',3,'My Simple Sentence','Read and build a short sentence about school.','learn',jsonb_build_object('intro','Build a simple sentence with a person, a verb and an idea.','steps',jsonb_build_array('Read the sentence slowly.','Put the word cards in order.','Check that the sentence makes sense.')))
 ) v(level_code,sort_order,title,objective,lesson_type,payload) on v.level_code=lv.code
)
insert into public.mrfluent_kids_lessons(unit_id,title,objective,lesson_type,lesson_payload,sort_order,is_published)
select unit_id,title,objective,lesson_type,payload,sort_order,false from lesson_data
on conflict(unit_id,sort_order) do update
set title=excluded.title,objective=excluded.objective,lesson_type=excluded.lesson_type,
    lesson_payload=excluded.lesson_payload,updated_at=now();