SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: authors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.authors (
    id bigint NOT NULL,
    name character varying NOT NULL,
    arxiv character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: authors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.authors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.authors_id_seq OWNED BY public.authors.id;


--
-- Name: authorships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.authorships (
    id bigint NOT NULL,
    author_id bigint NOT NULL,
    paper_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: authorships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.authorships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authorships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.authorships_id_seq OWNED BY public.authorships.id;


--
-- Name: bookmarks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookmarks (
    id bigint NOT NULL,
    paper_id bigint NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: bookmarks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookmarks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookmarks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookmarks_id_seq OWNED BY public.bookmarks.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id bigint NOT NULL,
    arxiv character varying,
    title character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    subject_id bigint NOT NULL
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: categorisations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categorisations (
    id bigint NOT NULL,
    paper_id bigint NOT NULL,
    category_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: categorisations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categorisations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categorisations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categorisations_id_seq OWNED BY public.categorisations.id;


--
-- Name: followships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.followships (
    id bigint NOT NULL,
    author_id bigint NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: followships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.followships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: followships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.followships_id_seq OWNED BY public.followships.id;


--
-- Name: friendly_id_slugs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.friendly_id_slugs (
    id bigint NOT NULL,
    slug character varying NOT NULL,
    sluggable_id integer NOT NULL,
    sluggable_type character varying(50),
    scope character varying,
    created_at timestamp(6) without time zone
);


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.friendly_id_slugs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.friendly_id_slugs_id_seq OWNED BY public.friendly_id_slugs.id;


--
-- Name: papers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.papers (
    id bigint NOT NULL,
    arxiv character varying,
    title character varying,
    abstract text,
    version character varying,
    submitted date NOT NULL,
    revised date,
    category_id bigint NOT NULL,
    comment text,
    abs character varying NOT NULL,
    pdf character varying,
    tags character varying[] DEFAULT '{}'::character varying[],
    journal_ref character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: papers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.papers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: papers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.papers_id_seq OWNED BY public.papers.id;


--
-- Name: recommendations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recommendations (
    id bigint NOT NULL,
    paper_id bigint NOT NULL,
    user_id bigint NOT NULL,
    score double precision DEFAULT 1.0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: recommendations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recommendations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recommendations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recommendations_id_seq OWNED BY public.recommendations.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: subjects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subjects (
    id bigint NOT NULL,
    title character varying,
    arxiv character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: subjects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subjects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subjects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subjects_id_seq OWNED BY public.subjects.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying NOT NULL,
    name character varying DEFAULT ''::character varying,
    author_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    prefs jsonb DEFAULT '{}'::jsonb NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp(6) without time zone,
    remember_created_at timestamp(6) without time zone
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: authors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authors ALTER COLUMN id SET DEFAULT nextval('public.authors_id_seq'::regclass);


--
-- Name: authorships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authorships ALTER COLUMN id SET DEFAULT nextval('public.authorships_id_seq'::regclass);


--
-- Name: bookmarks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookmarks ALTER COLUMN id SET DEFAULT nextval('public.bookmarks_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: categorisations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categorisations ALTER COLUMN id SET DEFAULT nextval('public.categorisations_id_seq'::regclass);


--
-- Name: followships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.followships ALTER COLUMN id SET DEFAULT nextval('public.followships_id_seq'::regclass);


--
-- Name: friendly_id_slugs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendly_id_slugs ALTER COLUMN id SET DEFAULT nextval('public.friendly_id_slugs_id_seq'::regclass);


--
-- Name: papers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.papers ALTER COLUMN id SET DEFAULT nextval('public.papers_id_seq'::regclass);


--
-- Name: recommendations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendations ALTER COLUMN id SET DEFAULT nextval('public.recommendations_id_seq'::regclass);


--
-- Name: subjects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subjects ALTER COLUMN id SET DEFAULT nextval('public.subjects_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: authors authors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authors
    ADD CONSTRAINT authors_pkey PRIMARY KEY (id);


--
-- Name: authorships authorships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authorships
    ADD CONSTRAINT authorships_pkey PRIMARY KEY (id);


--
-- Name: bookmarks bookmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookmarks
    ADD CONSTRAINT bookmarks_pkey PRIMARY KEY (id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: categorisations categorisations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categorisations
    ADD CONSTRAINT categorisations_pkey PRIMARY KEY (id);


--
-- Name: followships followships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.followships
    ADD CONSTRAINT followships_pkey PRIMARY KEY (id);


--
-- Name: friendly_id_slugs friendly_id_slugs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.friendly_id_slugs
    ADD CONSTRAINT friendly_id_slugs_pkey PRIMARY KEY (id);


--
-- Name: papers papers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.papers
    ADD CONSTRAINT papers_pkey PRIMARY KEY (id);


--
-- Name: recommendations recommendations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendations
    ADD CONSTRAINT recommendations_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: subjects subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_authors_on_arxiv; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_authors_on_arxiv ON public.authors USING btree (arxiv);


--
-- Name: index_authorships_on_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authorships_on_author_id ON public.authorships USING btree (author_id);


--
-- Name: index_authorships_on_paper_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authorships_on_paper_id ON public.authorships USING btree (paper_id);


--
-- Name: index_bookmarks_on_paper_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bookmarks_on_paper_id ON public.bookmarks USING btree (paper_id);


--
-- Name: index_bookmarks_on_paper_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_bookmarks_on_paper_id_and_user_id ON public.bookmarks USING btree (paper_id, user_id);


--
-- Name: index_bookmarks_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bookmarks_on_user_id ON public.bookmarks USING btree (user_id);


--
-- Name: index_categories_on_arxiv; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_categories_on_arxiv ON public.categories USING btree (arxiv);


--
-- Name: index_categories_on_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categories_on_subject_id ON public.categories USING btree (subject_id);


--
-- Name: index_categorisations_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categorisations_on_category_id ON public.categorisations USING btree (category_id);


--
-- Name: index_categorisations_on_paper_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_categorisations_on_paper_id ON public.categorisations USING btree (paper_id);


--
-- Name: index_categorisations_on_paper_id_and_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_categorisations_on_paper_id_and_category_id ON public.categorisations USING btree (paper_id, category_id);


--
-- Name: index_followships_on_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_followships_on_author_id ON public.followships USING btree (author_id);


--
-- Name: index_followships_on_author_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_followships_on_author_id_and_user_id ON public.followships USING btree (author_id, user_id);


--
-- Name: index_followships_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_followships_on_user_id ON public.followships USING btree (user_id);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type ON public.friendly_id_slugs USING btree (slug, sluggable_type);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope ON public.friendly_id_slugs USING btree (slug, sluggable_type, scope);


--
-- Name: index_friendly_id_slugs_on_sluggable_type_and_sluggable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_type_and_sluggable_id ON public.friendly_id_slugs USING btree (sluggable_type, sluggable_id);


--
-- Name: index_papers_on_arxiv; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_papers_on_arxiv ON public.papers USING btree (arxiv);


--
-- Name: index_papers_on_arxiv_and_version; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_papers_on_arxiv_and_version ON public.papers USING btree (arxiv, version);


--
-- Name: index_papers_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_papers_on_category_id ON public.papers USING btree (category_id);


--
-- Name: index_papers_on_submitted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_papers_on_submitted ON public.papers USING btree (submitted);


--
-- Name: index_papers_on_tags; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_papers_on_tags ON public.papers USING btree (tags);


--
-- Name: index_recommendations_on_paper_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_recommendations_on_paper_id ON public.recommendations USING btree (paper_id);


--
-- Name: index_recommendations_on_paper_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_recommendations_on_paper_id_and_user_id ON public.recommendations USING btree (paper_id, user_id);


--
-- Name: index_recommendations_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_recommendations_on_user_id ON public.recommendations USING btree (user_id);


--
-- Name: index_subjects_on_arxiv; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_subjects_on_arxiv ON public.subjects USING btree (arxiv);


--
-- Name: index_users_on_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_author_id ON public.users USING btree (author_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: bookmarks fk_rails_0560fccafc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookmarks
    ADD CONSTRAINT fk_rails_0560fccafc FOREIGN KEY (paper_id) REFERENCES public.papers(id);


--
-- Name: papers fk_rails_22509389bd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.papers
    ADD CONSTRAINT fk_rails_22509389bd FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- Name: categorisations fk_rails_2bdc953711; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categorisations
    ADD CONSTRAINT fk_rails_2bdc953711 FOREIGN KEY (paper_id) REFERENCES public.papers(id);


--
-- Name: followships fk_rails_458330adae; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.followships
    ADD CONSTRAINT fk_rails_458330adae FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: authorships fk_rails_925f77f584; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authorships
    ADD CONSTRAINT fk_rails_925f77f584 FOREIGN KEY (author_id) REFERENCES public.authors(id);


--
-- Name: followships fk_rails_964f63b944; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.followships
    ADD CONSTRAINT fk_rails_964f63b944 FOREIGN KEY (author_id) REFERENCES public.authors(id);


--
-- Name: users fk_rails_9ac60fc016; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_9ac60fc016 FOREIGN KEY (author_id) REFERENCES public.authors(id);


--
-- Name: authorships fk_rails_ac4978835b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.authorships
    ADD CONSTRAINT fk_rails_ac4978835b FOREIGN KEY (paper_id) REFERENCES public.papers(id);


--
-- Name: bookmarks fk_rails_c1ff6fa4ac; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookmarks
    ADD CONSTRAINT fk_rails_c1ff6fa4ac FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: categories fk_rails_e056845821; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT fk_rails_e056845821 FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- Name: recommendations fk_rails_e696723f80; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendations
    ADD CONSTRAINT fk_rails_e696723f80 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: categorisations fk_rails_eff4575d0d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categorisations
    ADD CONSTRAINT fk_rails_eff4575d0d FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- Name: recommendations fk_rails_f8c0fe4aee; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendations
    ADD CONSTRAINT fk_rails_f8c0fe4aee FOREIGN KEY (paper_id) REFERENCES public.papers(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20230715145201'),
('20230715150048'),
('20230715211303'),
('20230715215812'),
('20230715221956'),
('20230716050204'),
('20230716050339'),
('20230716051011'),
('20230716052228'),
('20230716053617'),
('20230716053905'),
('20230716055143'),
('20230716063858'),
('20230716064651'),
('20230716070432'),
('20230716073038'),
('20230717130228');


