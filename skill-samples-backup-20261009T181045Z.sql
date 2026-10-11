START TRANSACTION;
UPDATE players SET vocation=0,maglevel=0,skill_fist=10,skill_club=0,skill_sword=0,skill_axe=0,skill_dist=0,skill_shielding=0,skill_fishing=0 WHERE id=2;
UPDATE players SET vocation=1,maglevel=0,skill_fist=0,skill_club=0,skill_sword=0,skill_axe=0,skill_dist=0,skill_shielding=0,skill_fishing=0 WHERE id=3;
UPDATE players SET vocation=2,maglevel=0,skill_fist=10,skill_club=10,skill_sword=10,skill_axe=10,skill_dist=10,skill_shielding=10,skill_fishing=10 WHERE id=4;
UPDATE players SET vocation=3,maglevel=0,skill_fist=0,skill_club=0,skill_sword=0,skill_axe=0,skill_dist=0,skill_shielding=0,skill_fishing=0 WHERE id=5;
UPDATE players SET vocation=4,maglevel=0,skill_fist=0,skill_club=0,skill_sword=0,skill_axe=0,skill_dist=0,skill_shielding=0,skill_fishing=0 WHERE id=6;
UPDATE players SET vocation=5,maglevel=0,skill_fist=0,skill_club=0,skill_sword=0,skill_axe=0,skill_dist=0,skill_shielding=0,skill_fishing=0 WHERE id=7;
UPDATE players SET vocation=4,maglevel=0,skill_fist=0,skill_club=0,skill_sword=0,skill_axe=0,skill_dist=0,skill_shielding=0,skill_fishing=0 WHERE id=11;
COMMIT;
