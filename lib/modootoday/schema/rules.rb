# frozen_string_literal: true

module Modootoday
  # schema.org rules the checker applies to built JSON-LD: the vocabulary (vocab.txt, from script/schema-vocab),
  # required properties per type (schema.org and Google Search structured data guidelines) and recommended ones.
  module Schema
    VOCAB_FILE = File.expand_path("vocab.txt", __dir__)
    # Not schema.org properties, but documented by Google/schema.org Actions for SearchAction.
    EXTRA_PROPS = %w[query-input].freeze
    ARTICLE = %w[Article BlogPosting NewsArticle TechArticle Report ScholarlyArticle SocialMediaPosting].freeze
    PAGE = %w[WebPage AboutPage CollectionPage ContactPage FAQPage ProfilePage SearchResultsPage ItemPage QAPage].freeze
    # type => [required, recommended]; one alternative per entry ("a|b": either).
    RULES = {
      "WebSite" => [%w[name url], %w[inLanguage publisher]],
      "Organization" => [%w[name], %w[url logo]],
      "Person" => [%w[name], %w[url]],
      "BreadcrumbList" => [%w[itemListElement], []],
      "ListItem" => [%w[position], %w[name item|url]],
      "ItemList" => [%w[itemListElement], []],
      "JobPosting" => [%w[title description datePosted hiringOrganization jobLocation|applicantLocationRequirements], %w[employmentType validThrough baseSalary]],
      "Event" => [%w[name startDate location], %w[endDate eventStatus image description organizer offers]],
      "Course" => [%w[name description], %w[provider offers hasCourseInstance]],
      "PodcastEpisode" => [%w[name], %w[partOfSeries datePublished associatedMedia|audio]],
      "SoftwareApplication" => [%w[name], %w[offers applicationCategory operatingSystem]],
      "Offer" => [%w[price|priceSpecification priceCurrency|priceSpecification], %w[availability url]],
      "DefinedTermSet" => [%w[name], %w[hasDefinedTerm]],
      "DefinedTerm" => [%w[name], %w[description]],
      "Question" => [%w[name acceptedAnswer|suggestedAnswer], []],
      "Answer" => [%w[text], []],
      "SearchAction" => [%w[target query-input], []],
      "ImageObject" => [%w[url|contentUrl], []],
    }.merge(ARTICLE.to_h { |t| [t, [%w[headline], %w[datePublished dateModified author image]]] })
                 .merge(PAGE.to_h { |t| [t, [%w[name url], %w[inLanguage]]] })
                 .merge("FAQPage" => [%w[name url mainEntity], []], "ProfilePage" => [%w[name url], %w[mainEntity]]).freeze
    URL_KEYS = %w[@id url item logo image sameAs contentUrl embedUrl urlTemplate applicationUrl downloadUrl installUrl].freeze
    DATE_KEYS = %w[datePublished dateModified dateCreated datePosted validThrough startDate endDate uploadDate].freeze
    ISO_8601 = /\A\d{4}-\d{2}-\d{2}(T\d{2}:\d{2}(:\d{2}(\.\d+)?)?(Z|[+-]\d{2}:?\d{2})?)?\z/

    module_function

    def vocab
      @vocab ||= File.readlines(VOCAB_FILE, chomp: true).reject { |l| l.start_with?("#") }
                     .each_with_object({ "t" => {}, "p" => {} }) { |l, h| k, n = l.split(" ", 2); h[k][n] = true }
    end

    def type?(name) = vocab["t"].key?(name)
    def property?(name) = vocab["p"].key?(name) || EXTRA_PROPS.include?(name)
  end
end
