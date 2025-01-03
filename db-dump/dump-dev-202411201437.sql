PGDMP     #    %            
    |            dev    15.7    15.3 @    -           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            .           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            /           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            0           1262    16404    dev    DATABASE     o   CREATE DATABASE dev WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.UTF-8';
    DROP DATABASE dev;
                postgres    false                        2615    2200    public    SCHEMA        CREATE SCHEMA public;
    DROP SCHEMA public;
                pg_database_owner    false            1           0    0    SCHEMA public    COMMENT     6   COMMENT ON SCHEMA public IS 'standard public schema';
                   pg_database_owner    false    4            �            1259    16459    file_seq    SEQUENCE     w   CREATE SEQUENCE public.file_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999999
    CACHE 1;
    DROP SEQUENCE public.file_seq;
       public          postgres    false    4            �            1259    16685    ia_seq    SEQUENCE     u   CREATE SEQUENCE public.ia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999999
    CACHE 1;
    DROP SEQUENCE public.ia_seq;
       public          postgres    false    4            �            1259    16700    ia    TABLE     ;  CREATE TABLE public.ia (
    ia_seq bigint DEFAULT nextval('public.ia_seq'::regclass) NOT NULL,
    ia_id text NOT NULL,
    depth1 character varying(50) NOT NULL,
    depth2 character varying(50) NOT NULL,
    depth3 character varying(50) NOT NULL,
    depth4 character varying(50) NOT NULL,
    ia_num integer
);
    DROP TABLE public.ia;
       public         heap    postgres    false    227    4            �            1259    17013    payment_id_seq    SEQUENCE     }   CREATE SEQUENCE public.payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999999
    CACHE 1;
 %   DROP SEQUENCE public.payment_id_seq;
       public          postgres    false    4            �            1259    17030    payment_history    TABLE     �  CREATE TABLE public.payment_history (
    payment_history_id bigint DEFAULT nextval('public.payment_id_seq'::regclass) NOT NULL,
    user_id character varying(50) NOT NULL,
    date date NOT NULL,
    plan character varying(255) NOT NULL,
    amount bigint NOT NULL,
    method character varying(255) NOT NULL,
    status character varying(255) NOT NULL,
    receipt_url character varying(255)
);
 #   DROP TABLE public.payment_history;
       public         heap    postgres    false    235    4            �            1259    16914    payment_seq    SEQUENCE     z   CREATE SEQUENCE public.payment_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999999
    CACHE 1;
 "   DROP SEQUENCE public.payment_seq;
       public          postgres    false    4            �            1259    16915    payments    TABLE     �   CREATE TABLE public.payments (
    payment_id integer DEFAULT nextval('public.payment_seq'::regclass) NOT NULL,
    user_id integer,
    subscription_id integer,
    payment_date date,
    amount numeric(10,2),
    status character varying(50)
);
    DROP TABLE public.payments;
       public         heap    postgres    false    233    4            �            1259    16442    rfp_seq    SEQUENCE     v   CREATE SEQUENCE public.rfp_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999999
    CACHE 1;
    DROP SEQUENCE public.rfp_seq;
       public          postgres    false    4            �            1259    16558    rfp    TABLE       CREATE TABLE public.rfp (
    rfp_seq bigint DEFAULT nextval('public.rfp_seq'::regclass) NOT NULL,
    pro_name character varying(255),
    pro_period character varying(20),
    pro_budget character varying(50),
    pro_service text,
    pro_output text,
    pro_reference text,
    pro_ia text,
    pro_wbs text,
    user_session character varying(100),
    expected_budget character varying(50),
    expected_period character varying(20),
    pro_agency text,
    user_id character varying(100),
    pro_funcdesc text,
    wbs_doc text
);
    DROP TABLE public.rfp;
       public         heap    postgres    false    216    4            �            1259    16469    rfp_temp_seq    SEQUENCE     {   CREATE SEQUENCE public.rfp_temp_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999999
    CACHE 1;
 #   DROP SEQUENCE public.rfp_temp_seq;
       public          postgres    false    4            �            1259    16583    rfp_temp    TABLE     �  CREATE TABLE public.rfp_temp (
    rfp_temp_seq bigint DEFAULT nextval('public.rfp_temp_seq'::regclass) NOT NULL,
    pro_name character varying(255),
    pro_period character varying(30),
    pro_budget character varying(50),
    pro_agency text,
    pro_function text,
    pro_skill text,
    pro_description text,
    user_session character varying(100),
    pro_reference text,
    inserted_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
    DROP TABLE public.rfp_temp;
       public         heap    postgres    false    218    4            �            1259    16511    session    TABLE     �   CREATE TABLE public.session (
    sid character varying NOT NULL,
    sess json NOT NULL,
    expire timestamp(6) without time zone NOT NULL
);
    DROP TABLE public.session;
       public         heap    postgres    false    4            �            1259    16901    subscription_seq    SEQUENCE        CREATE SEQUENCE public.subscription_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999999
    CACHE 1;
 '   DROP SEQUENCE public.subscription_seq;
       public          postgres    false    4            �            1259    16908    subscriptions    TABLE     �   CREATE TABLE public.subscriptions (
    subscription_id integer DEFAULT nextval('public.subscription_seq'::regclass) NOT NULL,
    user_id integer,
    start_date date,
    end_date date,
    amount numeric(10,2),
    status character varying(50)
);
 !   DROP TABLE public.subscriptions;
       public         heap    postgres    false    231    4            �            1259    16565    text_file_test    TABLE     �   CREATE TABLE public.text_file_test (
    text_contents text,
    user_session character varying(100),
    inserted_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
 "   DROP TABLE public.text_file_test;
       public         heap    postgres    false    4            �            1259    16570 	   thread_id    TABLE     �   CREATE TABLE public.thread_id (
    thread_id character varying(100),
    user_session character varying(100),
    inserted_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
    DROP TABLE public.thread_id;
       public         heap    postgres    false    4            �            1259    16869    user_info_seq    SEQUENCE     |   CREATE SEQUENCE public.user_info_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999999
    CACHE 1;
 $   DROP SEQUENCE public.user_info_seq;
       public          postgres    false    4            �            1259    16877 	   user_info    TABLE     (  CREATE TABLE public.user_info (
    user_info_seq bigint DEFAULT nextval('public.user_info_seq'::regclass) NOT NULL,
    user_id character varying(50),
    user_password character varying(200),
    user_phone character varying(50),
    user_email character varying(100),
    subscription_status character varying(50),
    subscription_end_date date,
    subscription_new character varying(5),
    subscription_start_date date,
    available_num character varying(100),
    billing_key character varying(255),
    customer_key character varying(255)
);
    DROP TABLE public.user_info;
       public         heap    postgres    false    229    4            �            1259    16575 
   voice_file    TABLE     �   CREATE TABLE public.voice_file (
    file_seq bigint DEFAULT nextval('public.file_seq'::regclass) NOT NULL,
    file_name character varying(200),
    file_size character varying(200),
    user_session character varying(100)
);
    DROP TABLE public.voice_file;
       public         heap    postgres    false    217    4            �            1259    16591    wbs_seq    SEQUENCE     v   CREATE SEQUENCE public.wbs_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 99999999
    CACHE 1;
    DROP SEQUENCE public.wbs_seq;
       public          postgres    false    4            �            1259    16654    wbs    TABLE     2  CREATE TABLE public.wbs (
    wbs_seq bigint DEFAULT nextval('public.wbs_seq'::regclass) NOT NULL,
    wbs_id text NOT NULL,
    task_name character varying(255) NOT NULL,
    roles_involved character varying(255),
    start_month numeric(3,1) NOT NULL,
    end_month numeric(3,1),
    description text
);
    DROP TABLE public.wbs;
       public         heap    postgres    false    225    4            "          0    16700    ia 
   TABLE DATA           S   COPY public.ia (ia_seq, ia_id, depth1, depth2, depth3, depth4, ia_num) FROM stdin;
    public          postgres    false    228   BM       *          0    17030    payment_history 
   TABLE DATA           w   COPY public.payment_history (payment_history_id, user_id, date, plan, amount, method, status, receipt_url) FROM stdin;
    public          postgres    false    236   i       (          0    16915    payments 
   TABLE DATA           f   COPY public.payments (payment_id, user_id, subscription_id, payment_date, amount, status) FROM stdin;
    public          postgres    false    234   �i                 0    16558    rfp 
   TABLE DATA           �   COPY public.rfp (rfp_seq, pro_name, pro_period, pro_budget, pro_service, pro_output, pro_reference, pro_ia, pro_wbs, user_session, expected_budget, expected_period, pro_agency, user_id, pro_funcdesc, wbs_doc) FROM stdin;
    public          postgres    false    220   �i                 0    16583    rfp_temp 
   TABLE DATA           �   COPY public.rfp_temp (rfp_temp_seq, pro_name, pro_period, pro_budget, pro_agency, pro_function, pro_skill, pro_description, user_session, pro_reference, inserted_at) FROM stdin;
    public          postgres    false    224   A�                 0    16511    session 
   TABLE DATA           4   COPY public.session (sid, sess, expire) FROM stdin;
    public          postgres    false    219   R�       &          0    16908    subscriptions 
   TABLE DATA           g   COPY public.subscriptions (subscription_id, user_id, start_date, end_date, amount, status) FROM stdin;
    public          postgres    false    232   ��                 0    16565    text_file_test 
   TABLE DATA           R   COPY public.text_file_test (text_contents, user_session, inserted_at) FROM stdin;
    public          postgres    false    221   Ԛ                 0    16570 	   thread_id 
   TABLE DATA           I   COPY public.thread_id (thread_id, user_session, inserted_at) FROM stdin;
    public          postgres    false    222   ��       $          0    16877 	   user_info 
   TABLE DATA           �   COPY public.user_info (user_info_seq, user_id, user_password, user_phone, user_email, subscription_status, subscription_end_date, subscription_new, subscription_start_date, available_num, billing_key, customer_key) FROM stdin;
    public          postgres    false    230   ۷                 0    16575 
   voice_file 
   TABLE DATA           R   COPY public.voice_file (file_seq, file_name, file_size, user_session) FROM stdin;
    public          postgres    false    223   Ź                  0    16654    wbs 
   TABLE DATA           n   COPY public.wbs (wbs_seq, wbs_id, task_name, roles_involved, start_month, end_month, description) FROM stdin;
    public          postgres    false    226   ��       2           0    0    file_seq    SEQUENCE SET     8   SELECT pg_catalog.setval('public.file_seq', 458, true);
          public          postgres    false    217            3           0    0    ia_seq    SEQUENCE SET     8   SELECT pg_catalog.setval('public.ia_seq', 13078, true);
          public          postgres    false    227            4           0    0    payment_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.payment_id_seq', 9, true);
          public          postgres    false    235            5           0    0    payment_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.payment_seq', 1, false);
          public          postgres    false    233            6           0    0    rfp_seq    SEQUENCE SET     7   SELECT pg_catalog.setval('public.rfp_seq', 372, true);
          public          postgres    false    216            7           0    0    rfp_temp_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.rfp_temp_seq', 609, true);
          public          postgres    false    218            8           0    0    subscription_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.subscription_seq', 1, false);
          public          postgres    false    231            9           0    0    user_info_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.user_info_seq', 23, true);
          public          postgres    false    229            :           0    0    wbs_seq    SEQUENCE SET     8   SELECT pg_catalog.setval('public.wbs_seq', 2770, true);
          public          postgres    false    225            |           2606    16707 
   ia ia_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.ia
    ADD CONSTRAINT ia_pkey PRIMARY KEY (ia_seq);
 4   ALTER TABLE ONLY public.ia DROP CONSTRAINT ia_pkey;
       public            postgres    false    228            �           2606    17037 $   payment_history payment_history_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.payment_history
    ADD CONSTRAINT payment_history_pkey PRIMARY KEY (payment_history_id);
 N   ALTER TABLE ONLY public.payment_history DROP CONSTRAINT payment_history_pkey;
       public            postgres    false    236            �           2606    16920    payments payments_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (payment_id);
 @   ALTER TABLE ONLY public.payments DROP CONSTRAINT payments_pkey;
       public            postgres    false    234            p           2606    16693    rfp pro_ia_unique 
   CONSTRAINT     N   ALTER TABLE ONLY public.rfp
    ADD CONSTRAINT pro_ia_unique UNIQUE (pro_ia);
 ;   ALTER TABLE ONLY public.rfp DROP CONSTRAINT pro_ia_unique;
       public            postgres    false    220            r           2606    16617    rfp pro_wbs_unique 
   CONSTRAINT     P   ALTER TABLE ONLY public.rfp
    ADD CONSTRAINT pro_wbs_unique UNIQUE (pro_wbs);
 <   ALTER TABLE ONLY public.rfp DROP CONSTRAINT pro_wbs_unique;
       public            postgres    false    220            n           2606    16517    session session_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY public.session
    ADD CONSTRAINT session_pkey PRIMARY KEY (sid);
 >   ALTER TABLE ONLY public.session DROP CONSTRAINT session_pkey;
       public            postgres    false    219            �           2606    16913     subscriptions subscriptions_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (subscription_id);
 J   ALTER TABLE ONLY public.subscriptions DROP CONSTRAINT subscriptions_pkey;
       public            postgres    false    232            x           2606    16582    voice_file text_file_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.voice_file
    ADD CONSTRAINT text_file_pkey PRIMARY KEY (file_seq);
 C   ALTER TABLE ONLY public.voice_file DROP CONSTRAINT text_file_pkey;
       public            postgres    false    223            ~           2606    16882    user_info user_info_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public.user_info
    ADD CONSTRAINT user_info_pkey PRIMARY KEY (user_info_seq);
 B   ALTER TABLE ONLY public.user_info DROP CONSTRAINT user_info_pkey;
       public            postgres    false    230            v           2606    16574    thread_id user_session_unique 
   CONSTRAINT     `   ALTER TABLE ONLY public.thread_id
    ADD CONSTRAINT user_session_unique UNIQUE (user_session);
 G   ALTER TABLE ONLY public.thread_id DROP CONSTRAINT user_session_unique;
       public            postgres    false    222            t           2606    16590    rfp user_session_unique_rfp 
   CONSTRAINT     ^   ALTER TABLE ONLY public.rfp
    ADD CONSTRAINT user_session_unique_rfp UNIQUE (user_session);
 E   ALTER TABLE ONLY public.rfp DROP CONSTRAINT user_session_unique_rfp;
       public            postgres    false    220            z           2606    16661    wbs wbs_pkey 
   CONSTRAINT     O   ALTER TABLE ONLY public.wbs
    ADD CONSTRAINT wbs_pkey PRIMARY KEY (wbs_seq);
 6   ALTER TABLE ONLY public.wbs DROP CONSTRAINT wbs_pkey;
       public            postgres    false    226            l           1259    16518    IDX_session_expire    INDEX     J   CREATE INDEX "IDX_session_expire" ON public.session USING btree (expire);
 (   DROP INDEX public."IDX_session_expire";
       public            postgres    false    219            �           2606    16708    ia ia_ia_id_fkey    FK CONSTRAINT     o   ALTER TABLE ONLY public.ia
    ADD CONSTRAINT ia_ia_id_fkey FOREIGN KEY (ia_id) REFERENCES public.rfp(pro_ia);
 :   ALTER TABLE ONLY public.ia DROP CONSTRAINT ia_ia_id_fkey;
       public          postgres    false    4208    228    220            �           2606    16921 &   payments payments_subscription_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_subscription_id_fkey FOREIGN KEY (subscription_id) REFERENCES public.subscriptions(subscription_id);
 P   ALTER TABLE ONLY public.payments DROP CONSTRAINT payments_subscription_id_fkey;
       public          postgres    false    4224    234    232            �           2606    16662    wbs wbs_wbs_id_fkey    FK CONSTRAINT     t   ALTER TABLE ONLY public.wbs
    ADD CONSTRAINT wbs_wbs_id_fkey FOREIGN KEY (wbs_id) REFERENCES public.rfp(pro_wbs);
 =   ALTER TABLE ONLY public.wbs DROP CONSTRAINT wbs_wbs_id_fkey;
       public          postgres    false    4210    226    220            "      x���]o�H���ӿ�W�hm$������{�;4f�{�����ȁ;v��h{��eC����(��v���A"��X�U�*�/)�у�-Y�K�|O�:���Џ����pk�{;[A/7���{�~/ފ���C?޸w+��gǿ-�'�����o�Հ}~�����o�o�^6�-�(��:p����Å�ƞ����K����D����[����/<�^:�(z雳��;�t��N>g�c�^S��he��-����cv�B����e��|\^j�Gk�O>d{<����,��yz��K/����`�e������^��${��e�/NI4�b^D�������w�R�/.��l��Bu����_r7��ƅ���J��W�^v���~��.���k,}�e���C����tU�l�\('�����)Nѧ����壗�0�vry���X�W���${��Y��>"�����.~�ɵ��[�w�/�!��ƶP�/��*HL@�6�CӷG���A�j?�����+�������B�����:ۢ,_R��d'-;�_���.���nz�����J�#1��n1:)���v��;R�|z5�fO���o�vq����D,3Ǳ �}6~��@ۺq�>d⢎tr�3�"�F��Nv��T
�fu
��=��gmE ��u��קw����i������TBmlWZ\ﲔT^Ҡ�zӉ+~K`W�Q�:��O�Y_I,jI7��,��/��o,��xD�!�w��㘥`Z(��{6L�c����-	�φd)���h������:&�^,�I�	�����ӹ� M����,���N\�Wt�h�k2D^�_Wxh����x�X����b����̔@s_S�2{��zV�L���|ʚ�c�Ѭ�-�o����򝩄���"���O�m"}�n���� xh��%!�%�h#�(:�v	Ђ��#�@g/�#�a�o凋�R��%*h1�*����F����㟥"�v���Z���-5�zrq��=��8�1�$h���((�N����q�%(h�Z����;
:�J��e$�U��p�P�������F��z�@[3��
m����6���c��][%�v�!a6�F4�|>I?�{��D\7��M���y�e*�̸��OYWi��H��nS�wGj����O���:^s��h�s
h�*E��=��B@kU��3oA�U�E]EÍXV����흭�΀�_��{A8�%�f����l�;[ZU���a`�Y���J5���ub˚�����T	ש�Ϳ}ӦHCG�xz����Z�U�gJ���el*,��*��4��H�#$<��L'�E���_q���YY�GN�U=n��:̓s��$�j��1�0爢�מR>�<O?�J�UC�M���F«F�)�0��E��NE��DGF�h����񔌅�ٱ�ッe��h
��Թ��]\u���~>���W3���P�B�KG�#��C@=*���성;�_L�o��c�~/,��~���
e����٪Z,��t�G�������3&l�� ��J�,\�(��:�{_>'���!��|������Z��5��Z�|��EۆP:0P/�����( �����m�e�q�i"�aR�$@�6H�Ӟ��|D]�X��v�W���E��l�7UJ� mrM�~��&a�,² ����^���tr�Wƨ�ɢ�X��th�^9�������)���4�x��W�'����ۃӧ�%��'Oҷ�<���rb���=Gh;N�U�~!����mqu���U����Z5��e5��jJX��DLЂ�ˇ�z��9 4�`{��4����x�kx4�LD�&D�w�����#$�hۥqy���4��_>?*Og��cXY�7b�m��]��6ژ9�b�����x{�l���f/���ƽA���q�9�G���o�[���j�����zO�^T,���ſ�\�hG�������C�<á���X��8c��8���w�*}[�F���A�t������M�`%�Xz5�Lt��A���W�3��lr�O�=��.�}�����|ȗ���WD�����q6=�ˣy��Z�l��%Xf��ث$;�5����`�)�Jh��F�`H�0�<**<0H4��1���V�o�6�j�-�!Q0V4��K1�r-I�񢋄mM��a��hݺ�@'aum����N�J�������yfMW�W�ux֤�?L�o$�b���Z\�����py](�3j��N�Z/W�B�X-dL�$��K�\S����Iw�`�ҥ?�ߨҫ���P��5[�*h%��z)� %�*�������W�Hu�ܢ�*�w��4쯚r4����iH���d�1��hs-O��FR�b��	�`8hV��}��M��=at}�D����ڽQ�:!���~�z�h�z5�(Mnr�oˋ< }�aiHθ��Ø���'�~�#�� m�i����6�&�:�A<��v�j����4cư
I�MtE�
{���6�nK��s�X�hs�f祖��`[���k�����񍩇6��{���Yz��}��3��ba�h���e����=��� T$���\\}Vz�|;!M¨'�������\oQ˶���+��~Կ�����0�xg�v��^<���N0
b?�����T/�8\0"ȮM�L��s�v	9t�':�@#�A���bڏ�Gj`Lh��?���N�>d�/����߲�;B��K_�ȀWA��g�cE�e���^)J�`8�")&qџ�j�mj���/�	Fc�m��ƾC'&c�|�e�G���|�H���Əff��3K|�l<�������TB�@ILx�w��JhNPQ*�n�C5E���M�е�jR	M�(�DS,v�Jl>+{v���#׷��ӟ�(�,� ���W]4Cl��0�\JC:�c[�lHtum�����b��\ohw[�.�'&��nf*���O������H$�v�!�s�->��T�$��pg+
B�7�b���ao3�'=?޼�1ظ�b�~k�|l-�;S�����`=��eL�hؙ_�N��5�j6ȑw)��,�$t�>�m>��	�'c�� d���Tf8�Ө�2(��#�u�fk2-،�fy\���h�fm�I�AS��x����A��o��lԆ�E�!j:h��0D�ոQ�)@x�T�~Q�u���B����A�=S�����L.�+��6��'����uz�f^
�@����X��uH�^��uH�fU�X*g�Л<������쳐�>9�*�E�7��ծt�S��d��֌Ԧ�
|:��e���-^O՗�i�p�"����I }ͽ~x�(���S���@�q�>��Nyo��L�(̫1�6Q�?8�/�(�~�i[�J8�A�ա�(;_�j��tul�X��`�Ǜg���K�G���l^;HІM��u3t¡�W7mR�f(L�ζ��X�-�h�f]�}�~�-vV��s���,o�I�B5Y�H�$G!���YH��(�k�^�'��8Vӊ�QBX��Y�I���I�l2�v�j-���Ā)uqq���u4���� �>Kڤ�a���.�>�XP+;�|�4��JLԲ�L�Xo���"{9g9��D�kT�N\Qu���I0jP�:���Хյ���S� ���0�7*f��+�=
8�pmd�
)�@���F(*z�[�#�ѭd���Vo��
zA?���[�{�~G�;ۣ�-w1=��)�bz4���)�G�x=���:=�]~77�Ig~���k���¬G��:��7�'�awm렃��������*�
4��E�����~^f��� �A�9�j�Y�p˿N���/�E��ԝ��!h\Ǳ��z��C��ȋ�}�=kC/�>��WECПVͣ^8�ی�=�$@��$��G���Z�v� �A�aC��Ѝ[�=�'=�)'~m�Z�H:�&��t��4�bk�W�ա��G�C'n�~f��x��u�ŧü����L���#�t�(@[G��yN<;��=xG�p� z����( ����Q �&k{Y����c>\0�T]ڬ �  ^����:&�/�ło���gA���v<"
@�VGQ�����elF&�&td�Ϳ~S��@?�J���T��F��������pz�lv�Oe�f���J׾�y9D����5ܗ���뒛o���a�L�E�!�Y$�MWDr��	��R&�>wĆHu�~�x���:�B�4�*a1��z��Pxy�YtI�W��>�$hLk���x��o��z��27 Xa�Y:$�Ak<$[��$����[���E[<��Ѧ����)��Q+[�������tRY���	+�_����}Q���m�|ݴ�
���E@�#��Z�UD��OW�:A$�`�$���[Z�O������&w�!>h�Z~>����o�7Xz=�>N%4�®>)��b�c�������;�BZKaO� �*;�������]_�X�1��,��MOM����1�`��f#ӶgI��h	��R	MMM�j'`�V3���A�B-g��0by!Z�"%
�����@�8k�����0��-�]}Y�P �zT�c��b�Ox�"F���济�ל~н��hF.>$��Ƭ@��q��h���QI����#�]�Rh]�FJ�E�Vf�@[ٶ�+�6�˿���z��Q�e�����Lqrh�z�8���/�iJ�;��1�)a����������tq�AC�K^�|N@���k�"�t6����>�慾�|�X�FRh۩I�)�S�O=��cy<�nx���(�._c�����V��o��(�m��v/m�����~os3H���5��p���í?_�֐X�ʬ��d��^]WV(���������/�d��j����DG�툨�+��>^�S��'��S�ˑB�)�Nv�!2�qGJe�A�v��D|��&;4w�d'��^�0ى����<ى�AO���D\Й ��F
���O�Mk��>�QhJ��2%�Qv����;��C�}ԭnz9�KO�2V��>jZ��� ��G}����	A��D��>j=7V��P�A��'���8ǓS�I�]�8�CA�VkF��*�A��x9!���p��5��M������:��ߋ�U�f ��@��R2�H	4^+%54�F�7�}'c䐔@�V��2���@�bX}j��@�R�Ζ��h�mK_9G]ݫ�=I�#��m]���*��m����^l�X<B�FpE��K��C���2�m=-$�xE,�٬g/�~[,k�h��lD�xh�᪐1G/�*�{�^�E�Vs��.��p�ȡ��`Ĕ��ѓ�mc��Û��k�#�4�g�$0�t�'���F���Y"�
ճ,;mv���M��k�C�.��D���o�6C-�G� �|��[�O�h�VT]�OJhjQ�t��qc4Ӭ]����RK��
�,X5��o�+����@[+�a�r"�h3ֈT���ލ��f�QH>�У���	��)T��B<��s�ĝ2/�����c�1�$�MDW��Qv�����E����VftKt�j�X�:�� �o�L� ��N5T�'�|�nK.%@#�n��>مP�3Z�@s�=�٠��>sYC%�W/��IF�A/	�~/F۽�(��m�[�����ݘ������|�[z�m;D�`]H���$2Z�����o�z4x�ɭII%\��l���E������R�����U�9q����H�d]B�/{K�������ŵܹ��~~g��?[�Unlfj�BW
b��nzq�oQ�!з�a�$���'!hˎ��I��0|�V���`��a�$��j^�#�q�էrj�@����$)ܖ�z�����|J���A�mq�yQ����@}�p���^}f����9 ��(~3�F�m0���I$��yx����޳���P��^��Qǀ�g�>5qAW�\�+�b I�o'%F�Xvu�NHŠݭR�8
�@��`�o��A���|��;�����&Ί��w�?	'���b�j�!
��Z(�gُ��2X��ɬz<拜f�驗D��F"K�{���Y�������BNfe�ʗo+pKW��ͷ����)����g�{��߸p	��Z���,�̷ �+O�	��T��VYXٟ�H�����v�+:���pk3��^�$� �������m�lo���K��{���d����� d�.�6�ZУ���^����§���s���]�$YA���r����ׅ,
2�+tHe�6��l��</��Q ]e�.�?���췣��~w	�c�X]�gt{�lH�U3�
�Ռb���~v���w��e���u�f';6�g���g!RJu�iE���韽�䘥��V��t@���~ ,:�}֝l������]�vE�����w�*�c{q1�|�������F�p�j��>U�� �x�Ǹ�t׀���J��D�`p�(j+�.Hu��c=�`0�"Q�T����8���U�E�`���-�e��;� �H�����ۭ����㮛����>� �\u�=N�U���=�4�3�{ q�m�z�.	w"���ܔ�K�u\��Cj�����y)�=|t�u�d�H��`��I��EI��d�(��H�eX!*����{�1�_!J�:����A�����>���(<C��g�QxI�U�ߙ
��6����^���؍��ȣ�EM�օ,j����RWǪ��ME�HԤ)��ȵ�~w-ێ��ž�ؚ�����k��UD����W@�cyr ��k��Nm�,��5�2֤3a��pI# ��Z�: ���
�ڔF�q;$�#м] �M ����(&GI�p�~�@��<��P;q#z��!��"�Ǧ���Ws��C���)�>C�DP�:E��gO]������V�������t���+�z`hԒZ��DhЀΕ�Z������(���:&��I4"��/Ye���7ٳ���֒�¥hPד�i�:�&'2�J��;_��Y�(/>�����|�U�*x9�E{�X+G� ��w����r�<�.�>��_���W_�?~r0]      *   �   x�3�L�N,-614��4202�50�50�|�q���-
o����7���Ҁ���-�'��|Ӳ��歜%%V�����9�z����E�ɩ�%��\f���|ݽ�Վ03M,H0Ԉ��P��oLE3�S��b���� �"f�      (      x������ � �            x��][sב~��<��*�"0�[g����:����Ԧ6VR�T�T��(���5iQ�@6%Q.jQ�LV��A����s�>�(1�Z�ʶpz�9s��uݓ6��x��?�寶Ƿ��'���A�1�ە���B����E�7����\�& >���;I>MF��b����m��?�����������V��A�����w����V���7��Η��k���64 =����׋�w������A����p~L���y|�'���(v��MAϋ'ۣwGō����$��V�=)�RP?��o���+�w�|��_���C���4���>��=H����m7ɏLm�Y�99X�~�| �nO^�������}r���=��J�Wâ�P<�����q��_�ɟ���BPT��]ݐ�C{�I6�8�����D���A����I�W���o��� ��G��﨑��������������򯿨4W��+Y�����U�f�^]Z�/T[˭V��ʹ��v�B).��R<=U]�����~�՚�Jm���+W�$��ïd�����=Q"��X�I����v������8�%���d�f�S-�]:�j{�:�{��&�d��;�B��;�"T��s5tݞ��S+������%�66���0��,����x���ư�����o�1P<�%r���f��6�wOq�����~�ǏzB�����n�y辅hZK�w�I���ω��]�\����7[��̌��w��#SO6_��Z:�س����u2K8����`�x� ��7w�ꕫ(8q�.1��� �����±� �J��.u�qw��v.��::���U�Lڢ�0U�.��Umo_�U������IPמ�۾�LYWfq`���*�`����a�}�ZJ� �7q�ˁ������-����l���b�:,Ӡ@�6���bp]�-=S�֘U]������TP'�η��N�"��כ8�O��ϩ������A�=���b�\����,<��1�oO���gr�p��P�<u���2u�$�q@����^�ژ���X�n!��k�e���6�%����!�%*�P�^ܾ�>X�U��*��%��jB��8~m�\m�ӣ�)X�w5xVK��w���Dw$�\]���/�ɱ�r)U#�^*�:1��}ND�Dt�ӣ7Ϸ��Ҹr�5o�1x���R"������۾\/��������n(�?�앫m��t���t~��Pն������=��yk�-��n�~#����Zs�!�8���A͈	%3r����0/�(!��'yG-���G(J�߱n}����ړ�<��
��`�䞼ڞ�rZ���B�sV�C������^N�-�+� ��m����O.��?�oü��O�7���3|��wO�G�p�*��e�Z����B*�����
��`�a!���_�s�q-�U�����W���� }z�uK�.�^}�ڎ.����k��O�F�����z*�DX����a�T����������)82e��)@����Ⱦ��!z�H|#�y�b�9�2�D�#Nծ.A"�"Te�0 0���P�Sc��7�1P�a�  RxʝUw2+��Q]�D�)�\��1��R��
¶v��}�xg�!Q3�a�Za*��[�!�B��E�j� �v��)�������Ϋ�N�ۮ�(����ve��|��O++i��Rk/WWj�N5�d ��bu%�uZ�N����\���pY�|�K1���>1/$
�M(��Qt	�;��<��S1��C-ŋ���PT�.n"�"<�%�e��Y�G� �I���¥��AO��.��Q*#nxe	���b�+Wa/��R7�@8��b�<)�P�aH��!@/84���������L&i��Y�M��P�����GlT��5'?S�d40�1t�{�'���+2Pc�<�I�Հ�թX/�ӡP,b"b���[���0 �
�5���/�|���c�!� ��rt��] &kF���8���+Z��l�����/����`.Q�e��E�&ꓛ���v�Nl-��Yⶂ)�S�&X�` �Gl���vO�CO^���ʐ���۠�`
����iČZ|��8]ʔ!�La^<��G���w��P!μtZ|{����:��h���A�?�៭���S���4F�״��r���R�QM�Cz
���?t���L'�Vsh�7/��٤�N����A!øL]`QOf&����W���{���A�J)Ni�5R�F���
�|k�K\3r�?���<Ƿ'}���c�xCk���!k_Y;�o�`�ý��k5��F��35~|O�ju{�!k��ڎL(Q�֬ �`�v/k#1�H�ٵ�1�YkX�a~�����ua��B���E�*���:h*�@{7�a1�_:ڨB��d�~��/���q����l�o��3��b!���;�]X-���`g���<����H�BM�����R=U|u�?��/@�����xg(�t����5� �g@4)Β����ŋ�����Lg�V�lqd|���meaM�������̑�K�)7����B�5=�؅p��2�'i���i�SiN0������ɾVf@Q�4lG!~�~o���o�0�Jy�Ġ�:`������og�{�*m�02�$3��]>k��V�B"����Yj�1��o�C���x�0O��[@���^�z� jeP1������Xǰ A��q�z��]v�Eh�k�o-�0�&�Q�<��D�XH���׮ �h%/�,Y8f�@Wό��ɃVN�Jpa�!��|�Y�Rשּׁ.WWk𯬽֬.e�F��uZ˫K�tu���/}����6��4��gn��K��D!����9\��@�l�ƌ�ִ��}��4D�CZ�~�T�i����'�����Oe�qx��Cz#jx�9�W�(.9>�߯[�t
��_�Es1Lat,;`̸A���muPd�D�Zz�L:L��@-�k�� b?P�^�b��4��Ԙ:���)/�w�#I`�>EO���S�`��%�e�[n�.UY��K
��Ӣ���l�_X[�j$�����b�
��5I��ʧ�e�soC����O��
���
��@�$�K��V.��wW�>hlT���B�~��`���4"WR���A���4��k3�L���<W:Pr1� ]d��1���M�̦�'!���!4hD��#�+5��J���_�e5D-�.�Z�#K\=�h�7��+��K��zjXٟ������@�y_�*�T�~��C�>�(Q�g>��f�2WiJX0���ޜ��(d��_b��r�Ђ�Z|��!s��/�V�;N�J?���@C��o�_����~u�^���:W���wo�S�m�QS��4�}%����(�|�*am:J�U�?��O�X��v�6�*ҤǬ��(��òG��+�E]��q}Xct��[tk]\�:�Ei{�t�;W�n_YX]Zh�v��jk�,[]���+��Zg���i�5[���wʵ?f-��ǯ�oA�O;�č�}Yz�E(�G���r"km�27�,���di�cJJ8�(�-�҆瓒�F)���sQ�.
սk��xmZ�!�����'�y�O�_:WZ�R�7vż`q�i'
"qk�/RgH�/Gev�B�0J��b��X�1<g�ue�<��t�����B�4����9e��aQ�2���F	SfC|Y��
�0�קOjY��Ү0U&��5k�Fi�˩�zmi_����k�����X�w����7�A��E��K2�>�_���gLWE=cՅ�b�:�D��:�*��Х�G�`	�R`�!��%�_�!��u�����7a}Ƣh��ҺR�9����
�B[w3b?�P�rc�7�J,#dWeQ^%�u!@G�ށ+������^����� �"�
����٨=�a� ��x6��¢�;E�A�w�KХ�v�����]��B�1�1sT�ݴ,�JvǺ��S���Bo��w}��p�
:~�ʌ_+d�c�x��Ȫ3�/�U�;0���qL��ݎg,4ƨ,j��mK��xK��\sR�:%�{H	~���������3p    ����Hs�Y�+Xe�+A,�5���b�Ӑy����-��2��D)�Da7]�S�V���?���hH�S���u��c�q;)m�l3����Uo�Fa�Ȱb#��M���
b���A�j�g�v�^�� ����\�'S�0����$���J �1��#.Dǳ�M��њ~~gXY3�J�>{��f	q_oȪw ��fQ��֕���b�;ҶA�r3���Si��||�������=�����Av�>�!��歺��ԙ�@_�f��j��^���t�$�t"�FZq�\]^̚i���jT��B��i-��i���T[Zk�Z�
M�á|�wt��*ä���Y��kAz�vk�X�����:�2�{</K=��s(������Ԅ�Aw���e`Z\.�����X��IZ��Cb)�|�<��>Mc�d�VU������&r�&�2�d�ǘ��[���޶�Dgk�(���` �ć�A�0�����aG74�w���K�C#�|Z��<�ԳD\�1��J���6n�⢣���SNh�R�q��N8_��*4�C\'��B�Vվ�����Zt���]��rB�*oQ݈�;}\�>��5E�y+j�r"����˖�B�5j��;Y��U;��5��zR��f��W�?r�ã�~���#�A��g�\M�+�Hɜ������E�ד�T�"��%BJ�(,2Qtd$" I�nI�#��� :���{��+��C����ws�q M���9X���M��+��d>'&2�l��P+aXk����iȯW	%��0��~��~�c�F�C#��8!:�a6�l3���R3�xd��P���)�u�]�f�)�%����D\;�x�8�`E��T��0�0
���Ӂ��_/��ի�_]�$Cu0Y��_?�_|��pV�8��f,�u���R��X���ly�V�,�.VӬ�i.������
M	<�Uk��$�b*qbS��8q�jT3և!��p�9{��W*)	��(}�m��@#��ޠ'"Z���ȩ���D(�T(N|e��3a0����B�"��I��+�$�UXy ���@`SBx�<�)��j�7�x<��g�(�m�i	�R	Ը�2�HA�uH�ם=L0)#K4�Tc/�U�@�AWNyF�}ﱺ��F���L����Ԓ�]��"�l.,�J��ʞ�!���2}�*<x(��h8n�.1�. �, �E��#}ArG��@.�����Ew��ٚ	�s������DyO�dF %@�	Ȱc�S]m*�a(T:Il0���1b�O"n��Ɖ��ih��C��:�_+���VV��&r>�#q0sp/*��",ޏKiw��oS��4�䀭�����͗q@�0�-d4bB��Ѥ��/��Ɲ[�>>*+���:�[�;�aJ���$8�P<ew��;���`������Xͬ����_���yAˈ���̋�r���7�.
�8Z��Df~+�a��}K%h$��������D����#�����6\�å&�>�-�}�xS�At{��`�<=�e��U=G�T����D�*�Fu2�����f���L�-ij֫KYڨ.����b'�t��/PH쟏�E�E���� )�c�2%x
�t;��'������U_��:e�>ȍ��t}|=�=e�D��z����y�л��_݁��L��h��"�A��ʭ:tdٺYߕF 0\_�:w�2��?}.ZBV��$�2˲hh�I�.!�	�4�ɧq.�99���T�A��`V�O˩|o�׊$��.��sR�t���0��8�c`O��n��`���FG�[��L ���^�P���ׯ"�מFk ��>
��+Y^�w�n�)4nnD��I�qsC�:4���"nC]�������K���wuvq�aH��H^��h���ӽv�[{�!�|2r�(L��N1:':�H�J/*�CB��0���BAz�X݊k`���2�-"�ƚK���\����"F~6V��L�� ��6t>Fr�H$*�Hd��d�߱8@�A��G�,1�4t�<b�$9 �4���F��e	E�N=��"��ū
H�< �\��U������V��Z�b���^%�=@�.IkDYp�$����;&=�P"�4hG�'9�b����|�3y���̤��uI�{�܎2E��II��{Ȣ����A��C�~5WVQ��Zı���]�'4�I�=�u�<_M����`X�t�X�Յ���<�/�(�įr�I��e/�-�X�!v�˄�[�A|�8[�LE�ǟ�tƭ��Th��4e�V��5��2}C�GҮ&qR�
I���L����S0u�H`�-�Y�Y[�5|9�1�<��ܜ	�C������x�2�9��hM�Ц��Ӳ�L�W5,��.M��l/dK���+!6�SWޥb�,%b�8�:���]���g,�8L��t5d־��<{w5��#��fa�_Ͽ�ӹ!D�<5�b��s��!�!����Q ��[���u'�=oB������[㴑ط��ي��w�!y��Q/	����rJ�>��ߩ�����V��XMV�j��X�f+��J�T��.t:��v��v.PhJ�Ȉ��K�����;�������į12���z��w̕毘��%J���'�w���拳��\��y�l�(&��f��i��œ��>�hΊ�4t�S�C!��3$�ŉ�%�<��rYL���r!I �!}:)�p�pz9���O�A҆���b�.Gsf�� �~$PBC���Ov�̚��i�H�	x�<5��C`w����=���Of�y��)v���-�g6I��(?ޙ�Χ�6v��8[J������W����嬚-dk�N-[���������J��|�B�w�Lp�(T=�Qż?��a�d���G�L��%��#��'r�8����Ft�ι|���'��R����IFo������dl �N���� �����Η��3�&���z���}sƞQ�Pq�?�=AE��H�,R����ѱ��l������tÚG�%�d���cjU���b{��7C�0[JN���O���I�}��F��e��y�(����	2m�6��b�6���d�쭪1����5?� .��?C����1e�GI6�r_�L�07)�$rUۇ5�b<� |B%&��s;9�Bn5��A:.�{*�*�Q��W�\�!Wl��y�|��>�ԫ�l���'\�5j۫md��O��ϝh�6o�/�!�x�Sջ7�`}�����;���S�Tu�Ѻ���OU���E��&X+b���_c�Q����(�E��Ik!1_�Sj����l�Ig�� ��ODb��o��!!�6
����軖O�`p�B;zx\�Lȯl���U_�vB׼[���x6#�p��=kF���%��p���"���������@��TNb_���o�ȯGh�� �X�)��i$�R	v��(�4V�\k����{��Ei����8C=S�fcf\+ݜ��o��:ޛ�1h���Ys�0g�9�
��i�&#�J�Yh�����A m�'�>�u������	��M۪@C��5q�b�8��B�M�,7�����>� ��s�W�#9�I4����@c2������o��X��L/��w�uJ=Wta�T�$��a��^��s�	J�=֞l���J�|<Ƶ9���_�i���.�ڍV���W�Yc�Y]ZZZ�v:Y��-,חj�
}DLb¾��z��	ZΗ��Q֤	���"qe2�A��� _A�f�[RBp?�1�-�=����%��%NL�v���({8M��G�g'1q5�����{M����'�L&�9N�s�	��(oӬH)�7���h���8�@.u���R^�cK���-�*��T\���Ҝ �B��R�08���D��*��7�ejO�v�}r�`�u�c5�5�P�ʸ�9�>�`F���ѠE�%�E5�e Y��{RX%��|p�
��n�/�s3ׄHɉ��屒ڂUܾxЋFu�(�����b 9��vjBk<Q6$&�0;!�H�Z$y�/9) S  �}╙զᶺ�|8i6`P���ʽ��9�V���?�r(X����q"�b�6E;j�9x��R�P	1XQ|��>qb��)�mT�c'�1�B.$Gq��/BF�˓o�S#�̦L<�@��*�����(A��!~���b�7)�^�w9�\<�>�f<����@�Y}Rm��u����$�ǟ�����d
U���⯒��l`B��G�xJ��!&�yG0���L0�j�۾�`b<����$�|Q�6<ȓQ1�':
�o�Ddy��~�)���k��-����Nd6�������L�̙8P��(�������>�|�����8ra;
�I�z���p;y�@�KE|�H>���Y�^�b��8����A�{F�����n�QꞄYgfV̧�ԌX��O��A�O��� ɷ�m:D_�f���;�ޚ�� �F�ð�ꬶ�Z��l-T���R�,�W�K�啬�f��f����J+&=E�K+_��j	��_4��\�S��Z�9�Si�.Vd��\��(�D�(�3���5� �<�ˡƣט���!�!�x�oF^v�U"G}���*&}���d��~��	[G�$�=}K�eAn�1�Uv����=��X?
El=�T �+��G�|�@}],�*��C����j![����(,�0�b�)ޅ*��N��h0�_<�Hj�A�Џ���/�����-y��:A�A�#O�A$$w�Q86�H�*�x&$,|?0h�\1����N�'ʤq ���/������$���?r;��(�07�1q.���aĂ�\�Q�j�%('䎜K��5��~B.{E�<*V����G�=����I�X$|���qn&��'8,����R�nE��4���˝�R֪..���Ysm�����+�+�����^h�]�P�Q��r}�i>t�{W���YH�^a`l<V��az��C�	a�AO~�o?R��$����q��\ ���	)S��&��g��T3.���
:\Y"<�i4�i�Ŭh�Zb�ꮢ�i	4�by�R� ^�*�_M�>���&����]���A��L\�Ί����8��:�L�3�c�_$ъJn��~Ԍ������qRo��J�P:V:T����W�/��!���s��H��L��Y�����_�	Z�*JH3����S��UT	1b̀& �ZQp*�l��z���ߜ�!x1c3)1�����g�BI�=��RPˎ+no��Խڇ�{��KI�J�g���hԸ����D�v�I���Jk�Q�VW��Vm1��f������r��>6�s��S�&YU��AȞ�ș$q�*d\�zF���K4����=s��bU��b��vb�h~�yw�_�L�A��j E���x*FP¶�/ U~G�gK�]��:Q����[�!�U�%���҇i��ap�E����� RL���fb�ٝU}6y�6����I�*���7hs CͣT�B[D����"��NqJ���G�j4������N���3]κ"����	EB�M�$X��5�7>��0��i�WO4�b��%T:Z�}��1gMIVX���H���F��n
RS`zvn��TN.�s���'ӧ2q�����ze��O>�?jPA/         	  x��Ko���ԯ������=/�7�-Y 9�2/"G^$�fP�UDmLC�5�I�ڕ#ʡ��D���5��{�C��O�D���� !P�3���f��-LޏE/���o�P`j�f�*�+:Ej-�`&�L��qҙ\�e75D�%{M��nՐ��<���T��d�c����?C�!O2�o"{n���17Uy�4��`�����d�fȝ�|u�"�[���M��\�R[����_b8�mc�����d��ݶ����+{o�<m�Fe��c������K��C�� ��f{`=H눬cL�j��J3)��TPqe�!����z����o��UC<?o���Xo*	%��a���+�&�B���s�Ӆ��!���)�4N!�����~�ϟ�s�������M�e$�Fުa8��|����L������QM�5M����a,��7��iȣ,o����8Ɏ1�y�@���?�SfT���,*��l��.2�/�s���<���R���r�f@ �Ʌ3�I_�F6��K�V�Q�^�����1y7��0&X'Y�P��ķmJ|�3	�vLB�OH�D1O<�6[�L��'&7L�l�e�)9��l����T%�u^?��2�:���)�>��[�^�2�-#�T�O'�ï���Қ��{����:E��@����U~9��V�R�wc(3�.
�T�5={gu����Xq��پmʣ!��4�_��Nɐ�<ۆL>S-��ީ���.���5K����@&w�K�[�z�?�TϨF�C`O�2�6X1�[�;Þ\�0�;�[z*�5<�>�`��j�z���e*�	}r>3}�����$C6:�����v�l:�ɛ�P$�T�����L^5��{)65N��q�]*�܂�L�.V�4}4��;����b�c�.,���~���~���)��UE����OY�n�<Y�A�@��a�W_4;���n�Q�6u�&�{��l��b��@4ߡk{�!q��1�Y�P��^�z������fcrY<���Ϯ�����|:P���2�q���S�9�-L�א����@4�Q��,���6ԼZ�	=Q��5q���Q��d6kp�b	�kȲ�`)��*�*_�٨�,]�j�ӄ�x?��f��k���^q SyPUM؇ɚ���i%?W0�O�|\���\��7WÁ�KW�Ae��w�|���`�|��:Dᡁ4�l"�2��T�^�*��P^��J$��R��1?nM�͚|�kH�ӝl�âLU�_����4 j��`��`L�q��UU��;����Xc��~GYݜ�W��*�s)E�L���X`�ɸ��ܾ97������U�.z��u{�_Z�b��1�6���M��w��I%����7�UZ26�����Q��k���d<����l�_=���������¢Gn��l(�M�D�چ=Gu��ag�g��ͭ�����	����UKY�v�72�s��?T�	�zX��[�t�$.kE�U|��E�\�����W��*��ݼ��2�|jb�~Ro'f��"Ip�"A�2�yg�a^P)<y��m��_����R��OK�3�t�&+[Vɶ\��=�:��(gEssssss��'�9��0N"�P����C����%��$�%�;e�� ��́�~�cww�|�5�5�5�5�5�5�5�?��$0=`�ԬΓ�����v%t*�g�9����7�CM��p��y�^k����p ��������<����ԏHL���sT�KbNC�-'��{_���2�ˌ��wM
������n��5�5�5�5�5�5�5�?���D.w�\�&�6z@i慕��z����2�˔�\˴�m��g��kpMoMoMoMoMoM��G�V��ĥ�U(	��%����W1?��e�M�dR��8Л*�*���zv�;o�n�n�n�n�n����n����k����9	8�I���sC�A���N�Ӓ��t��㬪o�5�5�5�5�5�5�� �턹fl���]����1M�0��o����Ex�&�|���.`znk�ޚޚޚޚޚޚ�_����^G��'��R�J�|ύ����z3��S���s� Z-xizkzkzkzkzkzkz�r	X���GB�ǄۑC� 0Ir��fd����W�^�;���Koo呵9����j�����N�=⺉O�S�	>G�� dN���]����8-3�d��f��/���������_��7e��|2��Kl�'u9I��=4!��}�`�hŏJH76K��m�         U  x����n�@���)��V�� �a����bm$M�rPN��wM��d�f��7�	����EH�OҘp��o�c-���dл 7ˎ�dED�/�F�D����6yT�� C,`��C�*"<V�AIݺ`[UQ�>�*7Ҹ��s�
���M�$Ԋ*&�,��z��c~�2���i�l�"=y�����6�����>뢤B���حu�E����s�n�k�C�T[_܅Z>'�5��<��ԉ�1O��q�+p�!�D2�ץgP*/��NQ��l�a�Z�;S�*b�?�bȝ)+9�o9ZXe�⩿6�Q�k{�u�-�̐'vi�+q�<�q�l?      &      x������ � �            x��\[oIv~���v�fvg^��`d�<��>A`��HI-Ǥ�Ԋ�ZvKC�iK��;m��b:�?�����K]���$�h5��N�:��\��4�^����y�J�Ӳz�֧��������ϊ���\ϓ:ֻ�<����|���'I}���<֏o�Ѱ-�$�W�륽���lVŦ��l��~>�%�z�tS�4�K}�g����ݿ{��/�~�����_|u��W��߹{���_<��JI54y5��Uφ����eu���M�?����`��<}	Q@���:�=I�'�ɴz��WD��v�{�n��{�nn��Ͽ�\��fg����Ǐ��4I����Y}<1�����N�4<!�T���}{>��,�fv��2W��ku�'�uY]������ϙ����͌6	���aL�5�Sa����,��U��]��|6�ٮ�=�5sr:�ψ��D>�j��j�a@�E�iJ��цN�Y���"�����^���hAd�Xp�3�=[���\����MG�OW�s���]�#HAZ_��v�|�Y��i��,�D��(�)A�ռ~9o�䅨z;�_�{��hSi��I@@
��_$]ͣ�<!�Y�1��~Ds�Y���]>���*}�=����E�!5��(�E}��S�@] ۬J�Z�B�|5�N�NfP��z��>���yHIҜ�?f����x����0Άkh9�CY���l4�z�*�ID䠎'��@4��8I~��ɿ��/������wB�	���Z��ʡ���#�И�#�)�a���6�H!`D�i̯��-�>�}��Jb-t�k%t�(�Lg�L�<��M�l��#���z�ҳl��L�hB}v*��aߊ�9�_�!�GC���*T���ɰ�_p<|?�F���嚍i�_��C�9q4�d��ys}Q�Mb��,bC�To.�pC���\ף9%��$�ŊC���nV]��aX�sJ^�T��,�����u�X�BNq8����vCC�2F�%��4}|zF��~�#�Ys��4}��ʟoR����p��T-I}sV�O���2��Na���9�9;T��_�%q���������uܶc����u���*B�*�l�X��iW��;�M��B�}����l"��W]�	XH������W-�Ɠ�����a^�.ivޛ��p��+RhO3{{'���%�?�H�rHV�� �9΄ȂՃ��M����L$�wY�_4)L�	�������9-!�pt՛f8a�[o6��գ����pE�����S�PLs/�7���u�z|n�d��3M��g�8��(.��Mq&@���ZY�'&<5f#���4��rU]�h�	f�n��n�G^?��r��N�n?�����9�;�Pwfs�L�x�2��koe��V��g���פ6��� n�=��o�z��gt�{���[�,��ҥBQ���J��a˛���"$0 .�d3Ω�=C�#ڌ^�Hg�G�0ڤ<�a���X�C��ߪ,�8���Te�B�TPE�Y��1t�Nu���ӂ��Z��Jgd�)-@1RR�X4#��i�왦;\o�h~��]c��	̞�є`s���cE�!>�$�̀ :"�J��{ɯ!��3��hO�+H�I�ق�޻!�{�V2iP��rd��@0�������6�#X�t|��1b��y�z�_O/��ἕ|�$�Cq�F+O���y�f�i�_�CN�8�9L)��~罭��p2A��:B\��� /ه+[�w��|�P�mB9=�C�V���Ǻ^gt�$K���4\�����l;�&[S�aX����wC[�\O?G� �m��*�����T�!;�>��R���-�`�U]t��� =�i�7�2@��GǞ��X��&[��8�.n�]�	%A�]��U0:6�:�d��iQ=:d��3�'�����MZ�I��5���	��l��� `i!��q�RŌ	r�OU�J�R���+���2�@1$�����N�����׸*6���h���Q@X]͛�4�
�)�%���%3Ɉ��'�1�A��N�l�E}��6�3�gWy}�cg9(M���E�F�X]>����e�Zh�P��n�_�X_�� �L���y��78�F���]��&*�c�S$D�)����ɅMr�G"V�f�^ѹ��2E���B�ݦ�ai}>��9���tXo4_f2c�G����87�&n���^]\X&�r��4�7��g�OG&�a��F0i��o��p�0m�B///5�,�!�������\֮p�����ԩR������bI�@��?\4O�U:&��1SX�N�C'������ w�w�c�h{O�*FS(�J`p �7M6U�!��@�D�$��]��8�x�ſ�=5��:y����<��r���G�qD$�v��=_섅w-C�]�%^aM�mp�,T���Ś�	���O��$�D��,�k2�E?��$�����)o`�;�� OW �Z����M9��k�`��q~6��U��S�@B�2�m��ք��tD����GYfF��:3^j�D���k�w�#�P[��%�G^J�u��T�s�e�	to$#o�y�a���T���Y8���ԛ�H:�~��ےO�d+mE�HJ�/��X@w��9�"�Zx��rn���MlI�
"%I�\�����a�L��Q����������݌�.��`wPn�/�Rl�u���j�H��fkQn;?k��M�#F�=�(�1��ߥ/�`j�ƙ7Z�_��$�-!�%#���� ~�Yu+�9��$���{˿��?�t�H�^L-��y.C�C*#��R��"x]��p�Ǩ�$����"�Z��V�0��[��ɱ��W?���Z"�X�7�9m��4���G�{�gِ_�� �[����!�QtiHϤP
@h#�)(�;�a��I��<���:C*��|��>N�$����;[�SqW�8uʜYp	�h�M0L�r�(�p^g�J-��-���g�z���X�^��}���(����o�*R��h�>��B����+��$%>�^��S�N�$X��z%��$��m���/�ru1~̌մz�!	[	+�:8��I�J�0��y�g-S�ӏzo��b����)�)t�E��z�6�3g�����Cg�ۊ#4�Y�9G���tA�d�-��g|�֭��t`A������"�q]�� ] r��4��'٨�y�ױ� ����G�\-.��^�7#��Uk�ܠ^�N��|6YwLO^����v`;���>:(�7���O$�}�->�yC�Zg;ZQ+�o�<y�s�A�̅�%�W��I[�0D?o.4�j֥X�Řٷ�*0�%+���h�-�Z�.C�DPW^�ŪP�O���9��
g.�o���uؤ�)��J��v+)V !)�>���6Rb��m*}�d	���LуNn� ])��9�p6�,�9����9"��ȣ@�h�e���l'=cu�A����FZ�,u�0^ow�ٛ��׵  k���K��od�ɑ{Rxa��,������ܪ�i�'y�7QC�\[�~Xmn��޶X�����̱?�������� w�N⠞\feZ�����(o�3�i5��īG�W���b�T�_�W��t�OQ4M��r������M�b��E�	�p����~���SAr�\�	���8|�E��0�2O�/u�y������!���A��ɦn3a.�g>�%����A<4k�$埲CpB�K�C&�P0[���u+H��Z�L�a�����_9'~S?^4��s��8	s�
�L��t�}[�2����<E�W9���-ؗ���#�|��>'җ��-� ��B7ť�1A$���RﰚG7���J\�tL�2�A���A�]2ҥ3��/�[�u���Rn�մ�;c�SpH�?^���=��7�iݡ�
[������@F�l�z�r�-�Ū@�B bRЪڄؤ�=ڧ����qC�M�I2�lWt�.���{>����Eu�v}U��N��͖u�V�ܞ2� ߎ��vV�� �	  _��^�E3��'�sx�My2O5�!Ϥ�T<Ư:y�_U^�-�~�Ʒ,㚅]	c�l��Eq<裊 Ȇ�/�!$��ud��X��C?e\Yw���_�����=��$��@!�*�wǄh��3���� ZD�Es����L���[ݘf���T�ӆd^!i�O4�f���z}�}|>'�W�i�:����,�gO���+ZP���[!i�Q�w�:I��N����3���5������wtF
��`q�N`�llU�!�H@o��D{{IN$����f��ݲ��Q��IT��k>w�SM�ii�D�k+O�c�i�Z�v?e�\�|_c��q�/	��ƇO<�3;�h�oѿ�j�d�F�&,q\��7�j�K���F��$���v�f4�NA	m�/9%K{��J6Fu��h�P����/����Z���aP��88�+�Y\\��D�����L]�Q�9��W��D���<��Z�z:�?؃�K��)ވ����s�r�����l�*�m-8��	 ��4'��"��-i�H~�������C���C�-�ӖWrdH}<Y�ׁ�h�D���!Ɲ�r̶AV^
��̼�{wԲBےX�	�2��e���B����Upn�{2s��ٞ���*�<����<�H���Y�����{;V�Dn_�'E���"OkdJ�)�yUj'��j{�qW��`��H%T�0@�*�����ȓ���,�	y_r<0�~N2�h/��][���ҕbġ��Aoe_�5mWoe.��b7%����b�U�	J7�_'��A�v"�HK����Z��4Pv�*��I.�`���Z�/����X�H-����-k��uP'��aiQ���@��ޢ������YV0�9��M�(	O�C�M���_$�ы��T��l��I؋�:<w��3� ��i�����w����Nf�Խ�R/�z>����"Ă�.5C���81�2���<{�-1��_�F��v�%+^�a���ڬ�;jz����\�]zʘ��P#��ª�2^@"�r����6�\�W�S�ᄗ
�gb����ۤ3�a�^:.�tЃ�,����r]�i��Cke�-��z�J�o���ָ�WM@��ü���\ѭw�[��&�ˡtb"P����6*�;r�ٟA/|5���-~Wĵ�֋��v��ل՗/��\�'��77ߒ��U>'�Ȱ�7Zt�U�6�+�ҁ���*3$�v�d[a��1=	�9�ݸ���{� ��"R$Nn��B�P�A'K��Y�^�_q|H�>�.�a�c��\���BׇL�N��O�K�J�|��i�����*�£Tc��uK�*��/_=��Y�F����t<��bI�!��y��QZ��Q���T��o����h�a���r�4�����%�j�sUXN<#%[bȣj�ʊ�(/?�ʠO$.�h�nzIJG*m(�Ub	\���'��B�6�P��;�����sp�+�zx¿�p\4�KB�4'./D!z����):w��� �C��_ŷ�l�?L%X�.����#���֤2�V��?����l�;ۯ�@������Jo��$���ru�D�^f�`7�|�Mc*}�5vt���F�$�������0D����A$�� �:	�k���n�l�.���q$E���U?:e��ȱ��V��B�����:��J���S���8E�]��� 6��&�<�]9�D���"1�ŉV��A���Ǟ{zr����$�Z�� Ktl�N�ş��p�G�	(u�Öm��Y�v�ln���4�*T>!��L��_�iT7�4e\ �+���I���Dx��q6����G�$�◳a�벯��y��)�(	l�����;��z�|{o���oº�ܤ��WL���#��4h3� UZ�8pZ�a�e�š�0�D��X%��վ7��G5-�5�G6��R�GPa�G{�-R3�C��B�t�vl�|�5�*a�,���Z��?W��
p���sOOm8���.��r&-`Z�ئdK(����t�}f���]KXٚ�֡�n# ~B)yw�M^cw��,.�0�Y@�WZ�+mg�T���?Ս ���ض�&D߈sh��"���<�n�l5�d�+�I�Hɀ?-����y1d��D��_�bM��_w�jcffڣ`��5���s4	�l�+TrrF�qP4��u]�c�ጉU��[�]G:2߹����̷月�o���2���ꟁ~nsC�к6Cʡ�U򴝡�<��E�!�t)VI��;�?� ���3)�����إ�J���������|����_�����t����;���ˁ;��ԩ?Kk�9�H��v7}�|�C5�7��sQ��7@��G_��)�A��M�&�*��7�]�����I��'wR��ƹ�w����%��t�N~DȦƁu.�Y����]���ҀO��S_��y���%�A���ӠA)�t����V,TE�d���nY��Ƕ/�F���˟z������/����W�߽��W_޿��o�|��g��JZ�           x�]��R"IE�˯�8D^��K�	�] ����1yu��R��If���j�εw�,7�ſ��zp�x��v�^���?Fl�����xV��	�V	p(	�Ag��޻P	&����BՄ=)�V������Ʒo���-N[?������U*�
H�!���A)�4.��7�j&k!zLk�O��屝^�?c�\�N�I
g�"]W��f�,X�`,�O�{�,�+��5�7d���ut���b>9n>0��<]M�����hB�Y(�f��(��1E�~��9!1�糷��n�~t���C��8���vt�*�3�xi# �҄s�Gk��8�M-E��������'�����by�m�����f6����q��0@�^��Ԃ^b2���׵�;?��$��wk�N��i��ﳳ[�7�(|LO��얄���7!9e
���r�!'��|Ś��~����{���0$�~T,9fc�9�%J`IG��k�^ee�_� ��Ќ}�5�w<��8^?O�7�g�u�8��e�D�ʡ��-����J�^��,�|�yM�F)�=�M�s?��F���jp~����qE�ʢYC4� S�`�FHHhv��O�v|N5�֥��~�9<�#�m��v�ó����*Jc"�"W�#����qȽ1^�2�?����MOIť��O&�|\-��v���iu�_.��T)hT�6%?1���Y�.[n��>�����˿mki��/�����������>K�,h�%`�|Hdɯ���dv�~E�u�������8�O�      $   �  x���ˎ�0���S�`WMb;�; �K.�6��r%$�	2�1�Y���[�}�60Q�J�*Y�������d�ީT��@o�vC�p�����Yr�&�%>�j�t�ghd�����uϹ?ȼ� "��
A��(B�(󒽸�p�X���!`�ZS|������/����m#`<?K�V+�P�1}U8��x�o���6U�G3���d�Q�,��a����d�h��P�(�-�W%����E��j֭[� ��Z���ixXmm�o��*64�v_�0N>F,Cg=uφmȆ7��R���Z�� i�R{�w�����]�O��e�U[t��[zE�G��0ǹ?-��A��v�t�n�:��a���V�{|aZ֠i�X
Dm��o,�����T-}7D��%���)u�v$�i ���!Y�%I��o��I,�fM�H�Y �Q�A�#�L�E�A��(����?~�_-[xA�	k��t         �   x��=
�@���S��&�o6��'� �V� Z�iQP�(�`L�BP�ً�l���f�u�����w��o��,Q�<�k\�b2+©ət.JKG�ؘ(��C���#V��s*��#�A3�}ȵx�D�[�:(I���dB�DjaM"2%���2i��0��L[�����4�� ��W�            x��Y�nG]���WY��z?�DɂM�(AʂM?�ñ��#Pb��A26HN4�?����Tu��Ԍ{z.��͹�:��TR�T&)�eI��1EQN1҉֜1�t�7�q��qX����q�sV�������Ͱx<.O���8,������v�����6��f��~�Ѡ��8�����{nq�a�x',���ţ��9J㉀�6��dRGz��ֽ_��gW�`������y�W~ڮ�wkL�C�خ����`\�+ڐ�:/F�É��}ތ��xh}u�;'Y�::~�� ��v\��a�hX><�v� ��5�rp��8�����\��K��u�E&eY҄:,G'6Z��3�ȣ�*�n�0�r8r<ywU�m��9�ߔ�O�ױ���0�YoG�/6���j�8�t�͝:��\1��*g7��oŇAy��"���z������3�BZ��R��M^ X��W�|�cA`p��b^�pY0��}��X����:���\g�1`ֺk��?pa�1F��q�e��"��J�̥�L��w�%��e�l�[���YY�Ax�B��:e|����d|���\%����0�X%���j� �뤊)�:%&A)�1�1�V��B)'��1����]��9�R��G1�1`�m�0�Ѻ�5(�Y���%I�`%r5��H
����>^\�����;�s5í�|>�v����7��yi0�%�K���q�%�56��8�H��Y���K.-��o�/mN|j��������Md�0����V��a�a�g3ÀN�f�4\|S��႖�S�0�[[��DC#��M���aq����l���ڒ��Y�w-����H���Ũ ���� EC<�	��L!f�Ebf2���F�(�v���_��w.�ÿ������g��0C���
��;<�	o�ѽ-@a
��IK͂k��_�?�9Ja��k��!y%7k$�`X�4ol��ٓOn��o�1Ia3�
��PcGo7�&��Үq�	ii�8��%��}���:7U�v�l����Y@a	3����EQ0�u}��F�5Lx�[��d�yz�M00ص�$�־�����{"z��,�q�khȀ��&�b��H��)�
��Q��~�S!��8&��o�X�s�AD��{��"����KQ��[j}�m/UD�`�D�g`x+*`>k*�aH=s�%�T=طa��_Y�	ۃ��|,�:��{R
�v�85ݸ�dN�I� ��8�9�	OP�2�U��Y;�]��֦���J�r����h�<�����\v��O|�bh{�x����b,.� 0�_M���Cy�����f`m[k���UAq�ѥzV�?L��V�Z.W��{�S����2	���L_t��t��(��H�Q�Lj�Ķ�(�(��1'4�ڿ007\Q����ڼ�w��-q�n��5]q��� s�z���S ��B}{v��=T;6����>�9���]˨;­�rgF���q.R+��H&)�ϴ$��|Y��q�P��l���7Û�����:��ref��j�z��\%80����Yb�����セW�$��H�� .��UY���L2�EީN�]��Nw��8�<bS4k�]w�@ޚ������N���q�2�/���I���Joe�2�<�v9Y����b�q�B�^[���bh����Wk�<���U<|�"�tV@�װD�t����Z�@h�l	)��L ��i�8ʸ���gI��}�'��0�3/	�		�lY�|�*F����LJj2l��+�
�0��<s�덍�[��C     