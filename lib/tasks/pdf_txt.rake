namespace :data do
  pdfs = FileList['data/pdf/*.pdf']

  desc 'convert all pdfs to text'
  task pdf2txt: pdfs.map { |f|
    f.sub(%r{data/pdf/(.*).pdf$}, 'data/txt/\1.pdf.txt')
  }

  rule %r{data/pdf/.*\.pdf$} do |t|
    sh 'curl', '-L', '--output', t.name,
      "https://export.arxiv.org/pdf/#{t.name.sub(%r{.*/}, '')}" do |ok, _res|
      puts "Failed to download #{t.name}" unless ok
    end
  end

  rule(/\.pdf\.txt$/ => [
         proc { |f| f.sub(%r{data/txt/(.*).pdf.txt$}, 'data/pdf/\1.pdf') }
       ]) do |t|
    sh 'pdftotext', t.source, t.name do |ok, _res|
      puts "Failed to convert, probably not a pdf file (#{t.source})" unless ok
    end
  end
end

