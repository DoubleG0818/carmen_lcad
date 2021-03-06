/*!@file Media/MgzInputStream.C Read frames from movie files */

// //////////////////////////////////////////////////////////////////// //
// The iLab Neuromorphic Vision C++ Toolkit - Copyright (C) 2000-2005   //
// by the University of Southern California (USC) and the iLab at USC.  //
// See http://iLab.usc.edu for information about this project.          //
// //////////////////////////////////////////////////////////////////// //
// Major portions of the iLab Neuromorphic Vision Toolkit are protected //
// under the U.S. patent ``Computation of Intrinsic Perceptual Saliency //
// in Visual Environments, and Applications'' by Christof Koch and      //
// Laurent Itti, California Institute of Technology, 2001 (patent       //
// pending; application number 09/912,225 filed July 23, 2001; see      //
// http://pair.uspto.gov/cgi-bin/final/home.pl for current status).     //
// //////////////////////////////////////////////////////////////////// //
// This file is part of the iLab Neuromorphic Vision C++ Toolkit.       //
//                                                                      //
// The iLab Neuromorphic Vision C++ Toolkit is free software; you can   //
// redistribute it and/or modify it under the terms of the GNU General  //
// Public License as published by the Free Software Foundation; either  //
// version 2 of the License, or (at your option) any later version.     //
//                                                                      //
// The iLab Neuromorphic Vision C++ Toolkit is distributed in the hope  //
// that it will be useful, but WITHOUT ANY WARRANTY; without even the   //
// implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU General Public License for more details.       //
//                                                                      //
// You should have received a copy of the GNU General Public License    //
// along with the iLab Neuromorphic Vision C++ Toolkit; if not, write   //
// to the Free Software Foundation, Inc., 59 Temple Place, Suite 330,   //
// Boston, MA 02111-1307 USA.                                           //
// //////////////////////////////////////////////////////////////////// //
//
// Primary maintainer for this file: Rob Peters <rjpeters at usc dot edu>
// $HeadURL: svn://isvn.usc.edu/software/invt/trunk/saliency/src/Media/MgzInputStream.C $
// $Id: MgzInputStream.C 8602 2007-07-20 23:10:44Z rjpeters $
//

#ifndef MEDIA_MGZINPUTSTREAM_C_DEFINED
#define MEDIA_MGZINPUTSTREAM_C_DEFINED

#include "Media/MgzInputStream.H"

#include "Component/ModelOptionDef.H"
#include "Image/Image.H"
#include "Image/Pixels.H"
#include "Media/MediaOpts.H"
#include "Media/MgzDecoder.H"
#include "Raster/GenericFrame.H"
#include "Transport/TransportOpts.H"
#include "Util/Assert.H"
#include "Util/log.H"
#include "rutz/trace.h"

// ######################################################################
MgzInputStream::MgzInputStream(OptionManager& mgr,
                                 const std::string& descrName,
                                 const std::string& tagName) :
  FrameIstream(mgr, descrName, tagName),
  itsDecoder(NULL), itsFrame(), itsFrameSpec(), itsFrameSpecValid(false)
{ }

// ######################################################################
MgzInputStream::~MgzInputStream()
{
  delete itsDecoder;
}

// ######################################################################
void MgzInputStream::setConfigInfo(const std::string& filename)
{
  // NOTE: if you modify any behavior here, then please update the
  // corresponding documentation for the global "--in" option inside
  // the OPT_InputFrameSource definition in Media/MediaOpts.C

  this->setFileName(filename);
}

// ######################################################################
GenericFrameSpec MgzInputStream::peekFrameSpec()
{
GVX_TRACE(__PRETTY_FUNCTION__);

  if (!itsFrameSpecValid)
    {
      if (itsFrame.initialized() == false)
        itsFrame = readFrame();

      itsFrameSpec = itsFrame.frameSpec();
      itsFrameSpecValid = true;
    }

  return itsFrameSpec;
}

// ######################################################################
void MgzInputStream::setFileName(std::string fname)
{
GVX_TRACE(__PRETTY_FUNCTION__);

  if (itsDecoder) delete itsDecoder;
  itsDecoder = new MgzDecoder(fname);
}

// ######################################################################
GenericFrame MgzInputStream::readFrame()
{
GVX_TRACE(__PRETTY_FUNCTION__);

  if (itsDecoder == NULL) LFATAL("You need to setFileName() first");
  GenericFrame ret;

  // do we already have a frame because we peeked its specs?
  if (itsFrame.initialized()) { ret = itsFrame; itsFrame = GenericFrame(); }
  else ret = itsDecoder->readFrame();

  return ret;
}

// ######################################################################
/* So things look consistent in everyone's emacs... */
/* Local Variables: */
/* mode: c++ */
/* indent-tabs-mode: nil */
/* End: */

#endif // MEDIA_MGZINPUTSTREAM_C_DEFINED
