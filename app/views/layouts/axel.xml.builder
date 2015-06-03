xml.instruct!
xml.document do
  xml << metadata.to_xml

  xml << errors.to_xml

  xml.result do
    # Hack because rabl doesn't like having root-node-less things rendered
    # Example: users/me.rabl renders with a <hash> wrapped around it
    xml << xml_clean(yield)
  end
end
