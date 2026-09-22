import 'cv_canvas.dart';
import '../document/cv_section.dart';

// Built-in templates use explicit canvas frames (millimetres).
const classicCanvas = CvCanvas(
  pages: [
    CvCanvasPage(
      showPageNumber: true,
      elements: [
        CvCanvasElement(
          id: 'body',
          type: CvCanvasElementType.flow,
          x: 18,
          y: 18,
          width: 174,
          height: 261,
          palette: CvCanvasPalette.body,
          showHeader: true,
          includeRemaining: true,
          includeCustom: true,
          titleMargin: 0,
          sectionOrder: [],
          excludedSections: [],
        ),
      ],
    ),
  ],
);

const plainCanvas = CvCanvas(
  pages: [
    CvCanvasPage(
      showPageNumber: true,
      elements: [
        CvCanvasElement(
          id: 'body',
          type: CvCanvasElementType.flow,
          x: 18,
          y: 18,
          width: 174,
          height: 261,
          palette: CvCanvasPalette.body,
          showHeader: true,
          includeRemaining: true,
          includeCustom: true,
          titleMargin: 0,
          sectionOrder: [],
          excludedSections: [],
        ),
      ],
    ),
  ],
);

const bannerCanvas = CvCanvas(
  pages: [
    CvCanvasPage(
      showPageNumber: true,
      elements: [
        CvCanvasElement(
          id: 'body',
          type: CvCanvasElementType.flow,
          x: 18,
          y: 18,
          width: 174,
          height: 261,
          palette: CvCanvasPalette.body,
          showHeader: true,
          includeRemaining: true,
          includeCustom: true,
          titleMargin: 0,
          sectionOrder: [],
          excludedSections: [],
        ),
      ],
    ),
  ],
);

const compactCanvas = CvCanvas(
  pages: [
    CvCanvasPage(
      showPageNumber: true,
      elements: [
        CvCanvasElement(
          id: 'body',
          type: CvCanvasElementType.flow,
          x: 15,
          y: 15,
          width: 180,
          height: 267,
          palette: CvCanvasPalette.body,
          showHeader: true,
          includeRemaining: true,
          includeCustom: true,
          titleMargin: 0,
          sectionOrder: [],
          excludedSections: [],
        ),
      ],
    ),
  ],
);

const academicCanvas = CvCanvas(
  pages: [
    CvCanvasPage(
      showPageNumber: true,
      elements: [
        CvCanvasElement(
          id: 'body',
          type: CvCanvasElementType.flow,
          x: 18,
          y: 18,
          width: 174,
          height: 261,
          palette: CvCanvasPalette.body,
          showHeader: true,
          includeRemaining: true,
          includeCustom: true,
          titleMargin: 0,
          sectionOrder: [
            CvSection.profile,
            CvSection.education,
            CvSection.experiences,
          ],
          excludedSections: [],
        ),
      ],
    ),
  ],
);

const contrastCanvas = CvCanvas(
  pages: [
    CvCanvasPage(
      showPageNumber: true,
      elements: [
        CvCanvasElement(
          id: 'body',
          type: CvCanvasElementType.flow,
          x: 18,
          y: 18,
          width: 174,
          height: 261,
          palette: CvCanvasPalette.body,
          showHeader: true,
          includeRemaining: true,
          includeCustom: true,
          titleMargin: 0.26,
          sectionOrder: [],
          excludedSections: [],
        ),
      ],
    ),
  ],
);

const sidebarCanvas = CvCanvas(
  pages: [
    CvCanvasPage(
      showPageNumber: true,
      elements: [
        CvCanvasElement(
          id: 'sidebar-background',
          type: CvCanvasElementType.rectangle,
          x: 4.2333333333333325,
          y: 4.2333333333333325,
          width: 62.93333333333334,
          height: 288.53333333333336,
          radius: 5.644444444444444,
          palette: CvCanvasPalette.sidebar,
        ),
        CvCanvasElement(
          id: 'body',
          type: CvCanvasElementType.flow,
          x: 80.57222222222222,
          y: 15,
          width: 114.42777777777778,
          height: 267,
          palette: CvCanvasPalette.body,
          showHeader: true,
          includeRemaining: true,
          includeCustom: true,
          titleMargin: 0,
          sectionOrder: [],
          excludedSections: [CvSection.skills, CvSection.languages],
        ),
        CvCanvasElement(
          id: 'sidebar',
          type: CvCanvasElementType.flow,
          x: 9.17222222222222,
          y: 15,
          width: 53.055555555555564,
          height: 267,
          palette: CvCanvasPalette.sidebar,
          showContacts: true,
          showPhoto: true,
          sectionOrder: [CvSection.skills, CvSection.languages],
        ),
      ],
    ),
  ],
);

const lightSidebarCanvas = CvCanvas(
  pages: [
    CvCanvasPage(
      showPageNumber: true,
      elements: [
        CvCanvasElement(
          id: 'sidebar-background',
          type: CvCanvasElementType.rectangle,
          x: 147.03333333333333,
          y: 4.2333333333333325,
          width: 58.733333333333334,
          height: 288.53333333333336,
          radius: 5.644444444444444,
          palette: CvCanvasPalette.sidebar,
        ),
        CvCanvasElement(
          id: 'body',
          type: CvCanvasElementType.flow,
          x: 15,
          y: 15,
          width: 118.6277777777778,
          height: 267,
          palette: CvCanvasPalette.body,
          showHeader: true,
          includeRemaining: true,
          includeCustom: true,
          titleMargin: 0,
          sectionOrder: [],
          excludedSections: [CvSection.languages, CvSection.interests],
        ),
        CvCanvasElement(
          id: 'sidebar',
          type: CvCanvasElementType.flow,
          x: 151.97222222222223,
          y: 15,
          width: 48.85555555555556,
          height: 267,
          palette: CvCanvasPalette.sidebar,
          showContacts: true,
          showPhoto: false,
          sectionOrder: [CvSection.languages, CvSection.interests],
        ),
      ],
    ),
  ],
);
