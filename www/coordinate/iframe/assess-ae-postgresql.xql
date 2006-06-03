<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.4</version></rdbms>

   <fullquery name="uos_code">
     <querytext>
       SELECT n.uos_code
       FROM cc_uos_name n, cc_uos u
       WHERE u.uos_name_id = n.name_id
           AND u.uos_id = :uos_id
     </querytext>
   </fullquery>

   <fullquery name="latest_am">
     <querytext>
       SELECT s.latest_revision_id
           FROM cc_uos u, cc_uos_revisions r, cr_items i, cc_uos_assess s
           WHERE u.uos_id = :uos_id
           AND i.item_id = u.uos_id
           AND r.uos_revision_id = i.latest_revision
           AND s.parent_uos_id = :uos_id
     </querytext>
   </fullquery>

   <fullquery name="map_am_to_revision">
     <querytext>
       SELECT cc_uos_assess_method__map (
           :latest_revision_id,
           :method_id
       );
     </querytext>
   </fullquery>

   <fullquery name="am_update">
     <querytext>
       UPDATE cc_uos_assess_method
           SET name = :name,
	   identifier = :identifier,
	   description = :description,
	   weighting = :weighting
	   WHERE method_id = :method_id
     </querytext>
   </fullquery>

   <fullquery name="object_update">
     <querytext>
       UPDATE acs_objects
           SET modifying_user = :modifying_user,
	   modifying_ip = :modifying_ip,
	   package_id = :package_id
	   WHERE object_id = :method_id
     </querytext>
   </fullquery>

</queryset>
